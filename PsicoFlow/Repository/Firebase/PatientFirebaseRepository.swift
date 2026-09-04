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
    
    func fetchPatients(userId: String) async throws -> [Patient] {
        let snapshot = try await patientsCollection(userId: userId).getDocuments()
        var pacientes = snapshot.documents.compactMap { try? $0.data(as: Patient.self) }
        
        for i in 0..<pacientes.count {
            if let observacoes = pacientes[i].notes {
                pacientes[i].notes = EncryptionManager.shared.decrypt(base64String: observacoes, userId: userId)
            }
        }
        
        return pacientes
    }
    
    func savePatient(_ paciente: Patient, userId: String) async throws {
        var pacienteSeguro = paciente
        
        if let observacoes = pacienteSeguro.notes {
            pacienteSeguro.notes = EncryptionManager.shared.encrypt(text: observacoes, userId: userId)
        }
        
        try patientsCollection(userId: userId).document(pacienteSeguro.id).setData(from: pacienteSeguro)
    }
    
    func updatePatient(_ paciente: Patient, userId: String) async throws {
        var pacienteSeguro = paciente
        
        if let observacoes = pacienteSeguro.notes {
            pacienteSeguro.notes = EncryptionManager.shared.encrypt(text: observacoes, userId: userId)
        }
        
        try patientsCollection(userId: userId).document(pacienteSeguro.id).setData(from: pacienteSeguro, merge: true)
    }
    
    func deletePatientCascade(patientID: String, userId: String) async throws {
        let batch = db.batch()
        let userDocRef = db.collection("users").document(userId)
        
        let pacienteRef = userDocRef.collection("patients").document(patientID)
        batch.deleteDocument(pacienteRef)
        
        let sessoes = try await userDocRef.collection("sessions")
            .whereField("pacienteID", isEqualTo: patientID).getDocuments()
        for doc in sessoes.documents { batch.deleteDocument(doc.reference) }
        
        let pagamentos = try await userDocRef.collection("payments")
            .whereField("pacienteID", isEqualTo: patientID).getDocuments()
        for doc in pagamentos.documents { batch.deleteDocument(doc.reference) }
        
        let evolucoes = try await userDocRef.collection("evolutions")
            .whereField("pacienteID", isEqualTo: patientID).getDocuments()
        for doc in evolucoes.documents { batch.deleteDocument(doc.reference) }
        
        let sessoesFixas = try await userDocRef.collection("fixed_sessions")
            .whereField("pacienteID", isEqualTo: patientID).getDocuments()
        for doc in sessoesFixas.documents { batch.deleteDocument(doc.reference) }
        
        try await batch.commit()
    }
    
    func escutarPacientes(userId: String, onChange: @escaping ([Patient]) -> Void) -> ListenerRegistration {
        return patientsCollection(userId: userId).addSnapshotListener { snapshot, error in
            guard let documents = snapshot?.documents else {
                print("Erro ao ouvir pacientes: \(error?.localizedDescription ?? "Desconhecido")")
                return
            }
            
            var pacientes = documents.compactMap { try? $0.data(as: Patient.self) }
            
            for i in 0..<pacientes.count {
                if let observacoes = pacientes[i].notes {
                    pacientes[i].notes = EncryptionManager.shared.decrypt(base64String: observacoes, userId: userId)
                }
            }
            
            onChange(pacientes)
        }
    }
    
    func bloquearPacientesExcedentes(userId: String) async throws {
        let db = Firestore.firestore()
        let pacientesRef = db.collection("users").document(userId).collection("patients")
        
        let snapshot = try await pacientesRef.whereField("status", isEqualTo: PatientStatus.active.rawValue).getDocuments()
        
        var pacientesAtivos = snapshot.documents.compactMap { try? $0.data(as: Patient.self) }
        
        if pacientesAtivos.count <= 5 { return }
        
        pacientesAtivos.sort { $0.createdAt < $1.createdAt }
        let pacientesParaBloquear = Array(pacientesAtivos[5...])
        
        let batch = db.batch()
        
        for paciente in pacientesParaBloquear {
            let docRef = pacientesRef.document(paciente.id)
            batch.updateData([
                "status": PatientStatus.inactive.rawValue,
                "bloqueadoPeloSistema": true
            ], forDocument: docRef)
        }
        
        try await batch.commit()
        print("Bloqueio concluído: \(pacientesParaBloquear.count) pacientes foram inativados pelo sistema.")
    }
    
    func desbloquearPacientes(userId: String) async throws {
        let db = Firestore.firestore()
        let pacientesRef = db.collection("users").document(userId).collection("patients")
        
        let snapshot = try await pacientesRef.whereField("bloqueadoPeloSistema", isEqualTo: true).getDocuments()
        
        if snapshot.documents.isEmpty { return }
        
        let batch = db.batch()
        
        for document in snapshot.documents {
            batch.updateData([
                "status": PatientStatus.active.rawValue,
                "bloqueadoPeloSistema": false
            ], forDocument: document.reference)
        }
        
        try await batch.commit()
        print("Desbloqueio concluído: \(snapshot.documents.count) pacientes foram reativados.")
    }
}
