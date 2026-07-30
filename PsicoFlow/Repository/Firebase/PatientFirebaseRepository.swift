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
    
    /// Varre os pacientes do usuário ao perder o plano Pro e bloqueia os excedentes
    func bloquearPacientesExcedentes(userId: String) async throws {
        let db = Firestore.firestore()
        let pacientesRef = db.collection("users").document(userId).collection("patients")
        
        let snapshot = try await pacientesRef.whereField("status", isEqualTo: PatientStatus.ativo.rawValue).getDocuments()
        
        var pacientesAtivos = snapshot.documents.compactMap { doc -> Patient? in
            try? doc.data(as: Patient.self)
        }
        
        if pacientesAtivos.count <= 5 {
            return
        }
        
        pacientesAtivos.sort { $0.criadoEm < $1.criadoEm }
        
        let pacientesParaBloquear = Array(pacientesAtivos[5...])
        
        let batch = db.batch()
        
        for paciente in pacientesParaBloquear {
            let docRef = pacientesRef.document(paciente.id)
            batch.updateData([
                "status": PatientStatus.inativo.rawValue,
                "bloqueadoPeloSistema": true
            ], forDocument: docRef)
        }
        
        // Executa a atualização no banco de dados
        try await batch.commit()
        print("Bloqueio concluído: \(pacientesParaBloquear.count) pacientes foram inativados pelo sistema.")
    }
    
    /// Varre os pacientes bloqueados pelo sistema e devolve o status Ativo ao recuperar o plano Pro
    func desbloquearPacientes(userId: String) async throws {
        let db = Firestore.firestore()
        let pacientesRef = db.collection("users").document(userId).collection("patients")
        
        let snapshot = try await pacientesRef.whereField("bloqueadoPeloSistema", isEqualTo: true).getDocuments()
        
        if snapshot.documents.isEmpty {
            return
        }
        
        let batch = db.batch()
        
        for document in snapshot.documents {
            batch.updateData([
                "status": PatientStatus.ativo.rawValue,
                "bloqueadoPeloSistema": false
            ], forDocument: document.reference)
        }
        
        try await batch.commit()
        print("Desbloqueio concluído: \(snapshot.documents.count) pacientes foram reativados.")
    }
}
