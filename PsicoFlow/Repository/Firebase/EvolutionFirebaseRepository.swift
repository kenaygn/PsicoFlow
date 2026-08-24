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
        
        var evolucoes = snapshot.documents.compactMap { try? $0.data(as: Evolution.self) }
        
        for i in 0..<evolucoes.count {
            evolucoes[i].conteudo = EncryptionManager.shared.decrypt(base64String: evolucoes[i].conteudo, userId: userId)
        }
        
        return evolucoes
    }
    
    func salvarEvolucao(_ evolucao: Evolution, userId: String) async throws {
        var evolucaoSegura = evolucao
        
        evolucaoSegura.conteudo = EncryptionManager.shared.encrypt(text: evolucao.conteudo, userId: userId)
        
        try collection(userId: userId).document(evolucaoSegura.id).setData(from: evolucaoSegura)
    }
    
    func atualizarEvolucao(_ evolucao: Evolution, userId: String) async throws {
        var evolucaoSegura = evolucao
        
        evolucaoSegura.conteudo = EncryptionManager.shared.encrypt(text: evolucao.conteudo, userId: userId)
        
        try collection(userId: userId).document(evolucaoSegura.id).setData(from: evolucaoSegura, merge: true)
    }
    
    func deletarEvolucao(id: String, userId: String) async throws {
        try await collection(userId: userId).document(id).delete()
    }
}
