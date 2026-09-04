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
        return db.collection("users").document(userId).collection("fixedSessions")
    }
    
    func fetchFixedSessions(userId: String) async throws -> [FixedSession] {
        let snapshot = try await collection(userId: userId).getDocuments()
        return snapshot.documents.compactMap { try? $0.data(as: FixedSession.self) }
    }
    
    func saveFixedSession(_ fixedSession: FixedSession, userId: String) async throws {
        try collection(userId: userId).document(fixedSession.id).setData(from: fixedSession)
    }
    
    func updateFixedSession(_ fixedSession: FixedSession, userId: String) async throws {
        try collection(userId: userId).document(fixedSession.id).setData(from: fixedSession, merge: true)
    }
    
    func deleteFixedSession(id: String, userId: String) async throws {
        try await collection(userId: userId).document(id).delete()
    }
}
