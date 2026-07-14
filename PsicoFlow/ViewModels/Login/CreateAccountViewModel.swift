//
//  CreateAccountViewModel.swift
//  PsicoFlow
//
//  Created by Kenay on 14/07/26.
//

import Foundation
import SwiftUI
import Combine
import GoogleSignIn

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
    
    func processarLoginGoogle(authManager: AuthManager) {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let rootViewController = windowScene.windows.first(where: { $0.isKeyWindow })?.rootViewController else { return }
        
        carregando = true
        
        let clientID = "1009909587239-7ao6e15muokgops7nmfspdm0br01ijul.apps.googleusercontent.com"
        let config = GIDConfiguration(clientID: clientID)
        GIDSignIn.sharedInstance.configuration = config
        
        GIDSignIn.sharedInstance.signIn(withPresenting: rootViewController) { [weak self] result, error in
            // O [weak self] evita vazamento de memória enquanto o usuário está fora do app logando
            guard let self = self else { return }
            
            // Se der erro (ex: o usuário fechou a janela ou ficou sem internet)
            if let error = error {
                self.carregando = false
                
                if (error as NSError).code != -5 {
                    self.tituloErro = "Erro no Google"
                    self.mensagemErro = error.localizedDescription
                    self.exibirAlertaErro = true
                }
                return
            }
            
            // Se deu certo, extrai as senhas (tokens) que o Google devolveu
            guard let user = result?.user,
                  let idToken = user.idToken?.tokenString else {
                self.carregando = false
                return
            }
            
            // Repassa para o nosso AuthManager criar a conta no Firebase
            Task {
                do {
                    try await authManager.loginComGoogle(idToken: idToken, accessToken: user.accessToken.tokenString)
                    self.carregando = false
                } catch {
                    self.tituloErro = "Erro de Autenticação"
                    self.mensagemErro = error.localizedDescription
                    self.exibirAlertaErro = true
                    self.carregando = false
                }
            }
        }
    }
}
