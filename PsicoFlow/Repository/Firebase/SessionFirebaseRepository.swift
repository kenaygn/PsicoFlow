//
//  SessionFirebaseRepository.swift
//  PsicoFlow
//
//  Created by Kenay on 17/07/26.
//

import Foundation
import FirebaseFirestore

class FirebaseSessionRepository: SessionRepositoryProtocol {
    private let db = Firestore.firestore()
    
    private func collection(userId: String) -> CollectionReference {
        return db.collection("users").document(userId).collection("sessions")
    }
    
    func fetchSessoes(userId: String) async throws -> [Session] {
        let snapshot = try await collection(userId: userId).getDocuments()
        return snapshot.documents.compactMap { try? $0.data(as: Session.self) }
    }
    
    func atualizarSessao(_ sessao: Session, userId: String) async throws {
        try collection(userId: userId).document(sessao.id).setData(from: sessao, merge: true)
    }
    
    func salvarSessao(_ sessao: Session, userId: String) async throws {
        try collection(userId: userId).document(sessao.id).setData(from: sessao)
    }
    
    func deletarSessao(id: String, userId: String) async throws {
        try await collection(userId: userId).document(id).delete()
    }
}
