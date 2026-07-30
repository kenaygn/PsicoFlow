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
    
    func fetchSessoes(userId: String) async throws -> [Session] {
        let snapshot = try await collection(userId: userId).getDocuments()
        return snapshot.documents.compactMap { try? $0.data(as: Session.self) }
    }
    
    func atualizarSessao(_ sessao: Session, userId: String) async throws {
        try collection(userId: userId).document(sessao.id).setData(from: sessao)
    }
    
    func salvarSessao(_ sessao: Session, userId: String) async throws {
        try collection(userId: userId).document(sessao.id).setData(from: sessao)
    }
    
    func deletarSessao(id: String, userId: String) async throws {
        try await collection(userId: userId).document(id).delete()
    }
    
    /// Cria um túnel em tempo real com o Firestore para as sessões (Offline-First)
    func escutarSessoes(userId: String, onChange: @escaping ([Session]) -> Void) -> ListenerRegistration {
        return collection(userId: userId).addSnapshotListener { snapshot, error in
            guard let documents = snapshot?.documents else {
                print("Erro ao ouvir sessões: \(error?.localizedDescription ?? "Desconhecido")")
                return
            }
            
            let sessoes = documents.compactMap { try? $0.data(as: Session.self) }
            onChange(sessoes)
        }
    }
}
