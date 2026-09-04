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
import FirebaseFirestore
import GoogleSignIn
import Combine

@MainActor
class AuthManager: ObservableObject {
    
    static let shared = AuthManager()
    
    @Published var usuarioLogado: Bool = false
    @Published var usuarioID: String? = nil
    
    @Published var usuarioAtual: User? = nil
    
    @Published var carregandoDados: Bool = false
    
    private var authStateListenerHandle: AuthStateDidChangeListenerHandle?
    private let userRepository: UserRepositoryProtocol
    
    init(userRepository: UserRepositoryProtocol = UserFirebaseRepository()) {
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
    func buscarDadosDoUsuario(uid: String) async {
        do {
            self.usuarioAtual = try await userRepository.fetchUser(uid: uid)
        } catch {
            print("Erro ao buscar dados: \(error.localizedDescription)")
            self.usuarioAtual = nil
        }
    }
    
    func salvarPerfilCompleto(nome: String, crp: String, horaInicio: String, horaFim: String) async throws {
        guard let uid = self.usuarioID else {
            throw NSError(domain: "AuthManager", code: 401, userInfo: [NSLocalizedDescriptionKey: "Usuário não autenticado."])
        }
        
        let novoUsuario = User(
            id: uid,
            name: nome,
            crp: crp,
            premium: false,
            createdAt: Date(),
            workdayStart: horaInicio,
            workdayEnd: horaFim
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
        print("Iniciando exclusão completa da conta e dos dados...")
        guard let user = Auth.auth().currentUser else { return }
        let uid = user.uid
        let db = Firestore.firestore()
        
        let colecoesParaApagar = [
            "patients",
            "sessions",
            "evolutions",
            "payments",
            "fixed_sessions"
        ]
        
        for colecao in colecoesParaApagar {
            try await apagarColecaoInteira(nomeDaColecao: colecao, uid: uid, db: db)
        }
        
        try await db.collection("users").document(uid).delete()
        print("Dados do banco de dados excluídos com sucesso.")
        
        try await user.delete()
        print("Autenticação excluída com sucesso.")
        
        self.usuarioAtual = nil
        self.usuarioID = nil
        self.usuarioLogado = false
    }
    
    /// Função auxiliar que busca todos os documentos de uma coleção e os apaga em paralelo
    private func apagarColecaoInteira(nomeDaColecao: String, uid: String, db: Firestore) async throws {
        let colecaoRef = db.collection("users").document(uid).collection(nomeDaColecao)
        let snapshot = try await colecaoRef.getDocuments()
        
        // Se a coleção estiver vazia, não faz nada
        if snapshot.documents.isEmpty { return }
        
        // Usa TaskGroup para apagar documentos em paralelo, sendo muito mais rápido
        // e evitando o limite de 500 operações do WriteBatch.
        await withTaskGroup(of: Void.self) { group in
            for document in snapshot.documents {
                group.addTask {
                    do {
                        try await document.reference.delete()
                    } catch {
                        print("Erro ao apagar documento \(document.documentID) em \(nomeDaColecao): \(error)")
                    }
                }
            }
        }
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
