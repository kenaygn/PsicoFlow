//
//  UserFirebaseRepository.swift
//  PsicoFlow
//
//  Created by Kenay on 15/07/26.
//

import Foundation
import FirebaseFirestore

class UserFirebaseRepository: UserRepositoryProtocol {
    
    private let db = Firestore.firestore()
    
    private let collectionName = "users"
    
    func fetchUser(uid: String) async throws -> User? {
        let document = try await db.collection(collectionName).document(uid).getDocument()
        
        if document.exists {
            return try document.data(as: User.self)
        } else {
            return nil
        }
    }
    
    func saveUser(user: User) async throws {
        try db.collection(collectionName).document(user.id).setData(from: user)
    }
    
    func updateUser(user: User) async throws {
        try db.collection(collectionName).document(user.id).setData(from: user, merge: true)
    }
    
    func listenToUsers(uid: String, onChange: @escaping (User?) -> Void) -> ListenerRegistration {
        return db.collection(collectionName).document(uid).addSnapshotListener { snapshot, error in
            guard let document = snapshot, document.exists else {
                print("Erro ao ouvir usuário: \(error?.localizedDescription ?? "Desconhecido")")
                onChange(nil)
                return
            }
            
            let user = try? document.data(as: User.self)
            onChange(user)
        }
    }
}
