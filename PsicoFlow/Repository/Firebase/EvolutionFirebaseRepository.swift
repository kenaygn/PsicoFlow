//
//  EvolutionFirebaseRepository.swift
//  PsicoFlow
//
//  Created by Kenay on 17/07/26.
//

import Foundation
import FirebaseFirestore

class EvolutionFirebaseRepository: EvolutionRepositoryProtocol {
    private let db = Firestore.firestore()
    
    private func collection(userId: String) -> CollectionReference {
        return db.collection("users").document(userId).collection("evolutions")
    }
    
    func fetchEvolucoes(paraPacienteID pacienteID: String, userId: String) async throws -> [Evolution] {
        let snapshot = try await collection(userId: userId)
            .whereField("pacienteID", isEqualTo: pacienteID)
            .getDocuments()
        
        return snapshot.documents.compactMap { try? $0.data(as: Evolution.self) }
    }
    
    func salvarEvolucao(_ evolucao: Evolution, userId: String) async throws {
        try collection(userId: userId).document(evolucao.id).setData(from: evolucao)
    }
    
    func atualizarEvolucao(_ evolucao: Evolution, userId: String) async throws {
        try collection(userId: userId).document(evolucao.id).setData(from: evolucao, merge: true)
    }
    
    func deletarEvolucao(id: String, userId: String) async throws {
        try await collection(userId: userId).document(id).delete()
    }
}
