//
//  PatientFirebaseRepository.swift
//  PsicoFlow
//
//  Created by Kenay on 17/07/26.
//

import Foundation
import FirebaseFirestore

class PatientFirebaseRepository: PatientRepositoryProtocol {
    private let db = Firestore.firestore()
    
    private func patientsCollection(userId: String) -> CollectionReference {
        return db.collection("users").document(userId).collection("patients")
    }
    
    func fetchPacientes(userId: String) async throws -> [Patient] {
        let snapshot = try await patientsCollection(userId: userId).getDocuments()
        // Converte os documentos do Firebase de volta para a struct Patient
        return snapshot.documents.compactMap { try? $0.data(as: Patient.self) }
    }
    
    func salvarPaciente(_ paciente: Patient, userId: String) async throws {
        // Assume que 'paciente' possui uma propriedade 'id' (String)
        try patientsCollection(userId: userId).document(paciente.id).setData(from: paciente)
    }
    
    func atualizarPaciente(_ paciente: Patient, userId: String) async throws {
        try patientsCollection(userId: userId).document(paciente.id).setData(from: paciente, merge: true)
    }
    
    // MARK: - Exclusão em Cascata
    /// Exclui o paciente e todos os seus registros atrelados de forma atômica (tudo ou nada)
    func excluirPacienteEmCascata(pacienteID: String, userId: String) async throws {
        let batch = db.batch()
        let userDocRef = db.collection("users").document(userId)
        
        // 1. Prepara a exclusão do Paciente[cite: 21]
        let pacienteRef = userDocRef.collection("patients").document(pacienteID)
        batch.deleteDocument(pacienteRef)
        
        // 2. Busca e prepara exclusão das Sessões[cite: 23]
        let sessoes = try await userDocRef.collection("sessions")
            .whereField("pacienteID", isEqualTo: pacienteID).getDocuments()
        for doc in sessoes.documents { batch.deleteDocument(doc.reference) }
        
        // 3. Busca e prepara exclusão dos Pagamentos[cite: 22]
        let pagamentos = try await userDocRef.collection("payments")
            .whereField("pacienteID", isEqualTo: pacienteID).getDocuments()
        for doc in pagamentos.documents { batch.deleteDocument(doc.reference) }
        
        // 4. Busca e prepara exclusão das Evoluções[cite: 24]
        let evolucoes = try await userDocRef.collection("evolutions")
            .whereField("pacienteID", isEqualTo: pacienteID).getDocuments()
        for doc in evolucoes.documents { batch.deleteDocument(doc.reference) }
        
        // 5. Busca e prepara exclusão das Sessões Fixas / Contratos[cite: 25]
        let sessoesFixas = try await userDocRef.collection("fixed_sessions")
            .whereField("pacienteID", isEqualTo: pacienteID).getDocuments()
        for doc in sessoesFixas.documents { batch.deleteDocument(doc.reference) }
        
        // 6. Executa a exclusão de todos os documentos ao mesmo tempo!
        try await batch.commit()
    }
    
    /// Cria um túnel em tempo real com o Firestore para os pacientes (Offline-First)
    func escutarPacientes(userId: String, onChange: @escaping ([Patient]) -> Void) -> ListenerRegistration {
        return patientsCollection(userId: userId).addSnapshotListener { snapshot, error in
            guard let documents = snapshot?.documents else {
                print("Erro ao ouvir pacientes: \(error?.localizedDescription ?? "Desconhecido")")
                return
            }
            
            let pacientes = documents.compactMap { try? $0.data(as: Patient.self) }
            onChange(pacientes)
        }
    }
}
