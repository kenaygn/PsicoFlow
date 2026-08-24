//
//  LoginViewModel.swift
//  PsicoFlow
//
//  Created by Kenay on 14/07/26.
//

import Foundation
import SwiftUI
import Combine
import GoogleSignIn
import FirebaseAuth

class LoginViewModel: ObservableObject {
    @Published var email = ""
    @Published var senha = ""
    
    @Published var carregando = false
    @Published var tituloErro: String? = nil
    @Published var mensagemErro: String? = nil
    @Published var exibirAlertaErro = false
    @Published var mostrarAlertaRecuperacao = false
    
    @Published var tempoRestante = 0
    
    var nonceAtual: String?
    
    func executarLogin(authManager: AuthManager) {
        carregando = true
        mensagemErro = nil
        
        Task {
            do {
                try await authManager.fazerLogin(email: email, senha: senha)
                carregando = false
            } catch {
                tituloErro = "Erro ao entrar"
                mensagemErro = traduzirErroFirebase(error)
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
                tituloErro = "Erro ao recuperar senha"
                mensagemErro = traduzirErroFirebase(error)
                exibirAlertaErro = true
            }
        }
    }
    
    func processarLoginApple(idToken: String, nonce: String, authManager: AuthManager) {
        carregando = true
        Task {
            do {
                try await authManager.loginComApple(idToken: idToken, nonce: nonce)
                carregando = false
            } catch {
                tituloErro = "Erro na Apple"
                mensagemErro = traduzirErroFirebase(error)
                exibirAlertaErro = true
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
                    self.mensagemErro = self.traduzirErroFirebase(error) // Usando a tradução
                    self.exibirAlertaErro = true
                    self.carregando = false
                }
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
    
    private func traduzirErroFirebase(_ error: Error) -> String {
        let nsError = error as NSError
        
        if nsError.domain == AuthErrorDomain {
            if let errorCode = AuthErrorCode(rawValue: nsError.code) {
                switch errorCode {
                case .invalidEmail:
                    return "O formato do e-mail é inválido."
                case .wrongPassword, .userNotFound, .invalidCredential:
                    return "E-mail ou senha incorretos."
                case .userDisabled:
                    return "Esta conta foi desativada. Entre em contato com o suporte."
                case .emailAlreadyInUse:
                    return "Este e-mail já está cadastrado."
                case .networkError:
                    return "Parece que você está sem internet. Verifique sua conexão e tente novamente."
                case .tooManyRequests:
                    return "Muitas tentativas incorretas. Sua conta foi bloqueada temporariamente. Tente redefinir a senha ou aguarde alguns minutos."
                default:
                    return "Ocorreu um erro de autenticação. Tente novamente mais tarde."
                }
            }
        }
        
        return error.localizedDescription
    }
}
