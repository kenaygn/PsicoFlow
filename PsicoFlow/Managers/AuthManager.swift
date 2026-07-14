//
//  AuthManager.swift
//  PsicoFlow
//
//  Created by Kenay on 02/06/26.
//

//
//  AuthManager.swift
//  Psyes
//

import Foundation
import FirebaseAuth
import Combine

@MainActor
class AuthManager: ObservableObject {
    @Published var usuarioLogado: Bool = false
    @Published var usuarioID: String? = nil
    
    private var authStateListenerHandle: AuthStateDidChangeListenerHandle?
    
    init() {
        configurarListenerDeAutenticacao()
    }
    
    private func configurarListenerDeAutenticacao() {
        authStateListenerHandle = Auth.auth().addStateDidChangeListener { [weak self] _, user in
            self?.usuarioLogado = (user != nil)
            self?.usuarioID = user?.uid
        }
    }
    
    func criarConta(email: String, senha: String) async throws {
        // O Firebase já faz a validação se o e-mail é válido e se a senha é forte
        try await Auth.auth().createUser(withEmail: email, password: senha)
    }
    
    func fazerLogin(email: String, senha: String) async throws {
        try await Auth.auth().signIn(withEmail: email, password: senha)
    }
    
    func recuperarSenha(email: String) async throws {
        try await Auth.auth().sendPasswordReset(withEmail: email)
    }
    
    func sairDaConta() {
        print("Fazendo logout do Firebase...")
        do {
            try Auth.auth().signOut()
        } catch {
            print("Erro ao tentar sair da conta: \(error.localizedDescription)")
        }
    }
    
    func deletarConta() async throws {
        print("Deletando conta no Firebase...")
        guard let user = Auth.auth().currentUser else { return }
        try await user.delete()
    }
    
    func loginComApple(idToken: String, nonce: String) async throws {
        let credential = OAuthProvider.appleCredential(withIDToken: idToken,
                                                       rawNonce: nonce,
                                                       fullName: nil)
        
        try await Auth.auth().signIn(with: credential)
    }
}
