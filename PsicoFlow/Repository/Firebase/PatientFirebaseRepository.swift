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
}
