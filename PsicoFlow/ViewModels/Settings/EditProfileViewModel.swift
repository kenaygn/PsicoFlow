//
//  EditProfileViewModel.swift
//  PsicoFlow
//
//  Created by Kenay on 08/06/26.
//

import Foundation
import SwiftUI
import Combine
import FirebaseAuth // Necessário para gerenciar a autenticação e provedores

@MainActor
class EditProfileViewModel: ObservableObject {
    private var authManager: AuthManager
    private let userRepository: UserRepositoryProtocol
    
    @Published var nome: String = ""
    @Published var crp: String = ""
    
    @Published var senhaAtual: String = ""
    @Published var novaSenha: String = ""
    
    @Published var errorMessage: String? = nil
    @Published var isUpdating: Bool = false
    
    /// Verifica se o usuário fez login com E-mail e Senha (ignora Apple/Google)
    var isEmailProvider: Bool {
        guard let user = Auth.auth().currentUser else { return false }
        // "password" é a identificação interna do Firebase para E-mail e Senha
        return user.providerData.contains { $0.providerID == "password" }
    }
    
    init(authManager: AuthManager, userRepository: UserRepositoryProtocol = UserFirebaseRepository()) {
        self.authManager = authManager
        self.userRepository = userRepository
        carregarDadosAtuais()
    }
    
    var temAlteracoes: Bool {
        guard let user = authManager.usuarioAtual else { return false }
        
        let dadosMudaram = nome != user.nome || crp != user.crp
        
        let tentandoMudarSenha = isEmailProvider && !novaSenha.isEmpty && !senhaAtual.isEmpty
        
        let camposValidos = !nome.trimmingCharacters(in: .whitespaces).isEmpty
        
        return (dadosMudaram || tentandoMudarSenha) && camposValidos
    }
    
    private func carregarDadosAtuais() {
        guard let user = authManager.usuarioAtual else { return }
        self.nome = user.nome
        self.crp = user.crp
    }
    
    func salvarAlteracoes() async -> Bool {
        isUpdating = true
        defer { isUpdating = false }
        
        // 1. Atualizar Perfil no Firestore (se houve mudança)
        if let currentUser = authManager.usuarioAtual {
            var userAtualizado = currentUser
            userAtualizado.nome = self.nome
            userAtualizado.crp = self.crp
            
            do {
                try await userRepository.updateUser(user: userAtualizado)
            } catch {
                self.errorMessage = "Erro ao atualizar os dados: \(error.localizedDescription)"
                return false
            }
        }
        
        // 2. Atualizar Senha no FirebaseAuth (se aplicável e se for provedor de email)
        if isEmailProvider && !novaSenha.isEmpty && !senhaAtual.isEmpty {
            do {
                guard let user = Auth.auth().currentUser, let email = user.email else { return false }
                
                // Reautentica o usuário (exigência de segurança do Firebase)
                let credential = EmailAuthProvider.credential(withEmail: email, password: senhaAtual)
                try await user.reauthenticate(with: credential)
                
                // Atualiza a senha
                try await user.updatePassword(to: novaSenha)
                
                self.senhaAtual = ""
                self.novaSenha = ""
            } catch {
                self.errorMessage = "Erro ao alterar a senha. Verifique se a 'Senha Atual' está correta."
                return false
            }
        }
        
        return true // Sucesso total
    }
}
