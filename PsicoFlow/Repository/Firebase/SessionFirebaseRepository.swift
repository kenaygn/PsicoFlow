//
//  SessionFirebaseRepository.swift
//  PsicoFlow
//
//  Created by Kenay on 17/07/26.
//

import Foundation
import FirebaseFirestore

class SessionFirebaseRepository: SessionRepositoryProtocol {
    private let db = Firestore.firestore()
    
    private func collection(userId: String) -> CollectionReference {
        return db.collection("users").document(userId).collection("sessions")
    }
    
    func fetchSessions(userId: String) async throws -> [Session] {
        let snapshot = try await collection(userId: userId).getDocuments()
        return snapshot.documents.compactMap { try? $0.data(as: Session.self) }
    }
    
    func updateSession(_ session: Session, userId: String) async throws {
        try collection(userId: userId).document(session.id).setData(from: session)
    }
    
    func saveSession(_ session: Session, userId: String) async throws {
        try collection(userId: userId).document(session.id).setData(from: session)
    }
    
    func deleteSession(id: String, userId: String) async throws {
        try await collection(userId: userId).document(id).delete()
    }
    
    /// Creates a real-time tunnel with Firestore for sessions (Offline-First)
    func listenToSessions(userId: String, onChange: @escaping ([Session]) -> Void) -> ListenerRegistration {
        return collection(userId: userId).addSnapshotListener { snapshot, error in
            guard let documents = snapshot?.documents else {
                print("Error listening to sessions: \(error?.localizedDescription ?? "Unknown")")
                return
            }
            
            let sessions = documents.compactMap { try? $0.data(as: Session.self) }
            onChange(sessions)
        }
    }
}
