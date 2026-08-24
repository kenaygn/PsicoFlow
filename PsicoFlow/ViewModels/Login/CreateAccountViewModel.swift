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
import FirebaseAuth

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
                mostrarErro(titulo: "Erro ao criar conta", mensagem: traduzirErroFirebase(error))
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
                mostrarErro(titulo: "Erro na Apple", mensagem: traduzirErroFirebase(error))
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
            guard let self = self else { return }
            
            if let error = error {
                self.carregando = false
                
                if (error as NSError).code != -5 {
                    self.tituloErro = "Erro no Google"
                    self.mensagemErro = self.traduzirErroFirebase(error)
                    self.exibirAlertaErro = true
                }
                return
            }
            
            guard let user = result?.user,
                  let idToken = user.idToken?.tokenString else {
                self.carregando = false
                return
            }
            
            Task {
                do {
                    try await authManager.loginComGoogle(idToken: idToken, accessToken: user.accessToken.tokenString)
                    self.carregando = false
                } catch {
                    self.tituloErro = "Erro de Autenticação"
                    self.mensagemErro = self.traduzirErroFirebase(error)
                    self.exibirAlertaErro = true
                    self.carregando = false
                }
            }
        }
    }
    
    private func traduzirErroFirebase(_ error: Error) -> String {
        let nsError = error as NSError
        
        if nsError.domain == AuthErrorDomain {
            if let errorCode = AuthErrorCode(rawValue: nsError.code) {
                switch errorCode {
                case .invalidEmail:
                    return "O formato do e-mail é inválido."
                case .emailAlreadyInUse:
                    return "Este e-mail já está cadastrado. Tente voltar e fazer login."
                case .weakPassword:
                    return "A senha escolhida é muito fraca. Tente criar uma senha mais segura."
                case .networkError:
                    return "Parece que você está sem internet. Verifique sua conexão e tente novamente."
                case .tooManyRequests:
                    return "Muitas tentativas. Sua conta foi bloqueada temporariamente. Aguarde alguns minutos."
                default:
                    return "Ocorreu um erro na autenticação. Tente novamente mais tarde."
                }
            }
        }
        
        return error.localizedDescription
    }
}
