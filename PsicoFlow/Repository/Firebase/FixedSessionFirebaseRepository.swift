//
//  FixedSessionFirebaseRepository.swift
//  PsicoFlow
//
//  Created by Kenay on 17/07/26.
//

import Foundation
import FirebaseFirestore

class FixedSessionFirebaseRepository: FixedSessionRepositoryProtocol {
    private let db = Firestore.firestore()
    
    private func collection(userId: String) -> CollectionReference {
        return db.collection("users").document(userId).collection("fixed_sessions")
    }
    
    func fetchFixedSessions(userId: String) async throws -> [FixedSession] {
        let snapshot = try await collection(userId: userId).getDocuments()
        return snapshot.documents.compactMap { try? $0.data(as: FixedSession.self) }
    }
    
    func saveFixedSession(_ sessaoFixa: FixedSession, userId: String) async throws {
        try collection(userId: userId).document(sessaoFixa.id).setData(from: sessaoFixa)
    }
    
    func updateFixedSession(_ sessaoFixa: FixedSession, userId: String) async throws {
        try collection(userId: userId).document(sessaoFixa.id).setData(from: sessaoFixa, merge: true)
    }
    
    func deleteFixedSession(id: String, userId: String) async throws {
        try await collection(userId: userId).document(id).delete()
    }
}
