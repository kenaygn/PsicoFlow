//
//  CreateAccountViewModel.swift
//  PsicoFlow
//
//  Created by Kenay on 14/07/26.
//

import Foundation
import SwiftUI
import Combine

class CreateAccountViewModel: ObservableObject {
    @Published var email = ""
    @Published var senha = ""
    
    @Published var carregando = false
    @Published var tituloErro: String? = nil
    @Published var mensagemErro: String? = nil
    @Published var exibirAlertaErro = false
    
    var nonceAtual: String?
    
    func criarConta(authManager: AuthManager) {
        guard !email.trimmingCharacters(in: .whitespaces).isEmpty else {
            mostrarErro(titulo: "E-mail inválido", mensagem: "Por favor, digite um e-mail válido.")
            return
        }
        
        guard senha.count >= 6 else {
            mostrarErro(titulo: "Senha muito curta", mensagem: "Sua senha precisa ter pelo menos 6 caracteres.")
            return
        }
        
        carregando = true
        
        Task {
            do {
                try await authManager.criarConta(email: email, senha: senha)
                carregando = false
            } catch {
                mostrarErro(titulo: "Erro ao criar conta", mensagem: error.localizedDescription)
                carregando = false
            }
        }
    }
    
    private func mostrarErro(titulo: String, mensagem: String) {
        tituloErro = titulo
        mensagemErro = mensagem
        exibirAlertaErro = true
    }
    
    func processarLoginApple(idToken: String, nonce: String, authManager: AuthManager) {
        carregando = true
        Task {
            do {
                try await authManager.loginComApple(idToken: idToken, nonce: nonce)
                carregando = false
            } catch {
                mostrarErro(titulo: "Erro na Apple", mensagem: error.localizedDescription)
                carregando = false
            }
        }
    }
}
