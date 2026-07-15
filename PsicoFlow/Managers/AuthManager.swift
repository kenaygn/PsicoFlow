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
import GoogleSignIn
import Combine

@MainActor
class AuthManager: ObservableObject {
    @Published var usuarioLogado: Bool = false
    @Published var usuarioID: String? = nil
    
    @Published var usuarioAtual: User? = nil
    
    @Published var carregandoDados: Bool = false
    
    private var authStateListenerHandle: AuthStateDidChangeListenerHandle?
    private let userRepository: UserRepositoryProtocol
    
    init(userRepository: UserRepositoryProtocol = UserRepository()) {
        self.userRepository = userRepository
        configurarListenerDeAutenticacao()
    }
    
    private func configurarListenerDeAutenticacao() {
        authStateListenerHandle = Auth.auth().addStateDidChangeListener { [weak self] _, user in
            guard let self = self else { return }
            
            self.usuarioLogado = (user != nil)
            self.usuarioID = user?.uid
            
            if let uid = user?.uid {
                // Dizemos que começou a carregar
                self.carregandoDados = true
                Task {
                    await self.buscarDadosDoUsuario(uid: uid)
                    // Dizemos que terminou de carregar
                    self.carregandoDados = false
                }
            } else {
                self.usuarioAtual = nil
                self.carregandoDados = false
            }
        }
    }
    
    /// Busca o documento do usuário no Firestore e atualiza a interface
    private func buscarDadosDoUsuario(uid: String) async {
        do {
            self.usuarioAtual = try await userRepository.fetchUser(uid: uid)
        } catch {
            print("Erro ao buscar dados do usuário no Firestore: \(error.localizedDescription)")
            self.usuarioAtual = nil
        }
    }
    
    func salvarPerfilCompleto(nome: String, crp: String, horaInicio: String, horaFim: String) async throws {
        guard let uid = self.usuarioID else {
            throw NSError(domain: "AuthManager", code: 401, userInfo: [NSLocalizedDescriptionKey: "Usuário não autenticado."])
        }
        
        let novoUsuario = User(
            id: uid,
            nome: nome,
            crp: crp,
            premium: false,
            criadoEm: Date(),
            horaInicioExpediente: horaInicio,
            horaFimExpediente: horaFim
        )
        
        try await userRepository.saveUser(user: novoUsuario)
        
        self.usuarioAtual = novoUsuario
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
    
    func loginComGoogle(idToken: String, accessToken: String) async throws {
        let credential = GoogleAuthProvider.credential(withIDToken: idToken,
                                                       accessToken: accessToken)
        
        try await Auth.auth().signIn(with: credential)
    }
}
