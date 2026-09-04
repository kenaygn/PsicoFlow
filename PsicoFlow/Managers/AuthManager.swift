//
//  AuthManager.swift
//  PsicoFlow
//
//  Created by Kenay on 02/06/26.
//

//
//  AuthManager.swift
//  PsicoFlow
//

import Foundation
import FirebaseAuth
import FirebaseFirestore
import GoogleSignIn
import Combine

@MainActor
class AuthManager: ObservableObject {
    
    static let shared = AuthManager()
    
    @Published var userLoggedIn: Bool = false
    @Published var userID: String? = nil
    
    @Published var currentUser: User? = nil
    
    @Published var loadingData: Bool = false
    
    private var authStateListenerHandle: AuthStateDidChangeListenerHandle?
    private let userRepository: UserRepositoryProtocol
    
    init(userRepository: UserRepositoryProtocol = UserFirebaseRepository()) {
        self.userRepository = userRepository
        setupAuthStateListener()
    }
    
    private func setupAuthStateListener() {
        authStateListenerHandle = Auth.auth().addStateDidChangeListener { [weak self] _, user in
            guard let self = self else { return }
            
            self.userLoggedIn = (user != nil)
            self.userID = user?.uid
            
            if let uid = user?.uid {
                self.loadingData = true
                Task {
                    await self.fetchUserData(uid: uid)
                    self.loadingData = false
                }
            } else {
                self.currentUser = nil
                self.loadingData = false
            }
        }
    }
    
    /// Fetches the user's document from Firestore and updates the interface
    func fetchUserData(uid: String) async {
        do {
            self.currentUser = try await userRepository.fetchUser(uid: uid)
        } catch {
            print("Error fetching data: \(error.localizedDescription)")
            self.currentUser = nil
        }
    }
    
    func saveCompleteProfile(name: String, crp: String, workdayStart: String, workdayEnd: String) async throws {
        guard let uid = self.userID else {
            throw NSError(domain: "AuthManager", code: 401, userInfo: [NSLocalizedDescriptionKey: "User not authenticated."])
        }
        
        let newUser = User(
            id: uid,
            name: name,
            crp: crp,
            premium: false,
            createdAt: Date(),
            workdayStart: workdayStart,
            workdayEnd: workdayEnd
        )
        
        try await userRepository.saveUser(user: newUser)
        
        self.currentUser = newUser
    }
    
    func createAccount(email: String, password: String) async throws {
        try await Auth.auth().createUser(withEmail: email, password: password)
    }
    
    func login(email: String, password: String) async throws {
        try await Auth.auth().signIn(withEmail: email, password: password)
    }
    
    func recoverPassword(email: String) async throws {
        try await Auth.auth().sendPasswordReset(withEmail: email)
    }
    
    func signOut() {
        print("Signing out of Firebase...")
        do {
            try Auth.auth().signOut()
        } catch {
            print("Error signing out: \(error.localizedDescription)")
        }
    }
    
    func deleteAccount() async throws {
        print("Starting complete account and data deletion...")
        guard let user = Auth.auth().currentUser else { return }
        let uid = user.uid
        let db = Firestore.firestore()
        
        let collectionsToDelete = [
            "patients",
            "sessions",
            "progressNotes",
            "payments",
            "fixedSessions"
        ]
        
        for collectionName in collectionsToDelete {
            try await deleteEntireCollection(collectionName: collectionName, uid: uid, db: db)
        }
        
        try await db.collection("users").document(uid).delete()
        print("Database data deleted successfully.")
        
        try await user.delete()
        print("Authentication deleted successfully.")
        
        self.currentUser = nil
        self.userID = nil
        self.userLoggedIn = false
    }
    
    /// Helper function that fetches all documents in a collection and deletes them in parallel
    private func deleteEntireCollection(collectionName: String, uid: String, db: Firestore) async throws {
        let collectionRef = db.collection("users").document(uid).collection(collectionName)
        let snapshot = try await collectionRef.getDocuments()
        
        if snapshot.documents.isEmpty { return }
        
        await withTaskGroup(of: Void.self) { group in
            for document in snapshot.documents {
                group.addTask {
                    do {
                        try await document.reference.delete()
                    } catch {
                        print("Error deleting document \(document.documentID) in \(collectionName): \(error)")
                    }
                }
            }
        }
    }
    
    func loginWithApple(idToken: String, nonce: String) async throws {
        let credential = OAuthProvider.appleCredential(withIDToken: idToken,
                                                       rawNonce: nonce,
                                                       fullName: nil)
        
        try await Auth.auth().signIn(with: credential)
    }
    
    func loginWithGoogle(idToken: String, accessToken: String) async throws {
        let credential = GoogleAuthProvider.credential(withIDToken: idToken,
                                                       accessToken: accessToken)
        
        try await Auth.auth().signIn(with: credential)
    }
}
