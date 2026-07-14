//
//  EditProfileViewModel.swift
//  PsicoFlow
//
//  Created by Kenay on 08/06/26.
//

import Foundation
import SwiftUI
import Combine

class EditProfileViewModel: ObservableObject {
    private var authManager: AuthManager
    
    @Published var nome: String = ""
    @Published var email: String = ""
    @Published var crp: String = ""
    
    @Published var senhaAtual: String = ""
    @Published var novaSenha: String = ""
    @Published var confirmarNovaSenha: String = ""
    
    var senhasDivergem: Bool {
        !confirmarNovaSenha.isEmpty && novaSenha != confirmarNovaSenha
    }
    
    init(authManager: AuthManager) {
        self.authManager = authManager
        carregarDadosAtuais()
    }
    
    var temAlteracoes: Bool {
//        guard let user = authManager.currentUser else { return false }
//        
//        let dadosMudaram = nome != user.nome || email != user.email || crp != user.crp
//        
//        let tentandoMudarSenha = !senhaAtual.isEmpty || !novaSenha.isEmpty || !confirmarNovaSenha.isEmpty
//        
//        var senhasValidas = true
//        if tentandoMudarSenha {
//            senhasValidas = !senhaAtual.isEmpty && !novaSenha.isEmpty && (novaSenha == confirmarNovaSenha)
//        }
//        
//        let camposValidos = !nome.trimmingCharacters(in: .whitespaces).isEmpty && !email.trimmingCharacters(in: .whitespaces).isEmpty
//        
//        return (dadosMudaram || tentandoMudarSenha) && camposValidos && senhasValidas
        return true
    }
    
    private func carregarDadosAtuais() {
//        guard let user = authManager.currentUser else { return }
//        self.nome = user.nome
//        self.email = user.email
//        self.crp = user.crp
    }
    
    func salvarAlteracoes() {
//        authManager.currentUser?.nome = nome
//        authManager.currentUser?.email = email
//        authManager.currentUser?.crp = crp
        
        // Futuramente: Lógica do Firebase para trocar senha
    }
}
