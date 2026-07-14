//
//  LoginViewModel.swift
//  PsicoFlow
//
//  Created by Kenay on 14/07/26.
//

import Foundation
import SwiftUI
import Combine

@MainActor
class LoginViewModel: ObservableObject {
    @Published var email = ""
    @Published var senha = ""
    
    @Published var carregando = false
    @Published var tituloErro: String? = nil
    @Published var mensagemErro: String? = nil
    @Published var exibirAlertaErro = false
    @Published var mostrarAlertaRecuperacao = false
    
    @Published var tempoRestante = 0
    
    
    func executarLogin(authManager: AuthManager) {
        carregando = true
        mensagemErro = nil
        
        Task {
            do {
                try await authManager.fazerLogin(email: email, senha: senha)
                // Se der certo, o AuthManager muda o estado e a RootView altera a tela sozinha!
                carregando = false
            } catch {
                tituloErro = "Erro ao entrar"
                mensagemErro = error.localizedDescription
                exibirAlertaErro = true
                carregando = false
            }
        }
    }
    
    func executarRecuperacaoDeSenha(authManager: AuthManager) {
        guard !email.trimmingCharacters(in: .whitespaces).isEmpty else {
            tituloErro = "Email inválido"
            mensagemErro = "Por favor, digite seu e-mail no campo acima para recuperar a senha."
            exibirAlertaErro = true
            return
        }
        
        carregando = true
        
        Task {
            do {
                try await authManager.recuperarSenha(email: email)
                carregando = false
                mostrarAlertaRecuperacao = true
                
                iniciarCronometro()
            } catch {
                carregando = false
                mensagemErro = error.localizedDescription
                exibirAlertaErro = true
            }
        }
    }
    
    private func iniciarCronometro() {
            tempoRestante = 60
            
            Task {
                while tempoRestante > 0 {
                    try? await Task.sleep(nanoseconds: 1_000_000_000)
                    tempoRestante -= 1
                }
            }
        }
}
