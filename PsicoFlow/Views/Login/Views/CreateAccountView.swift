//
//  CreateAccountView.swift
//  PsicoFlow
//
//  Created by Kenay on 14/07/26.
//

import SwiftUI
import AuthenticationServices

struct CreateAccountView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var authManager: AuthManager
    
    @State private var exibirTermos = false
    @State private var exibirPrivacidade = false
    
    @StateObject private var vm = CreateAccountViewModel()
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 24) {
                // MARK: - 1. HERO SECTION
                VStack(alignment: .leading, spacing: 16) {
                    // Espaçador para compensar a área segura do Notch/Dynamic Island
                    Spacer()
                        .frame(height: 60)
                    
                    Text("Crie sua conta gratuita")
                        .font(.system(.title, design: .rounded))
                        .bold()
                    
                    // Texto corrido inspirado no GitHub
                    Text("Explore os recursos essenciais do Psyes para simplificar sua gestão e focar no que realmente importa: seus pacientes.")
                        .font(.subheadline)
                        .opacity(0.9)
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 24)
                .padding(.bottom, 140) // Aumentamos um pouco o espaço aqui para o degradê acontecer antes do texto acabar
                
                .background(
                    LinearGradient(
                        colors: [
                            Color.teal,
                            Color.teal.opacity(0.8), // Mantém a cor forte onde está o texto
                            Color(.systemBackground) // Fica transparente/mescla exatamente no limite com o resto do app
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                    
                )
                
                // A Logo continua como Overlay, aproveitando a transição do fundo
                .overlay(alignment: .bottom) {
                    HStack {
                        Rectangle()
                            .frame(height: 2)
                            .foregroundColor(Color(.white))
                        Text("Psyes")
                            .font(.system(.largeTitle, design: .rounded))
                            .foregroundStyle(Color.white)
                            .bold()
                            .shadow(color: .teal.opacity(0.2), radius: 5, y: 0) // Sombra levemente esverdeada para harmonizar
                        
                        Rectangle()
                            .frame(height: 2)
                            .foregroundColor(Color(.white))
                    }
                    .offset(y: -64)
                    .padding(.horizontal)
                    
                    
                }
                
                
                
                Text("Criar conta no Psyes")
                    .font(.headline)
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal)
                    .padding(.top, -40)
                
                // MARK: - 4. OPÇÕES SOCIAIS (Google & Apple)
                VStack(spacing: 12) {
                    // Botão Nativo da Apple
                    SignInWithAppleButton(.continue) { request in
                        //Gera a criptografia antes de abrir o FaceID
                        let nonce = AppleSignInHelper.randomNonceString()
                        vm.nonceAtual = nonce
                        
                        // Avisamos a Apple o que queremos acessar (e-mail e nome)
                        request.requestedScopes = [.fullName, .email]
                        request.nonce = AppleSignInHelper.sha256(nonce)
                        
                    } onCompletion: { result in
                        //O usuário colocou o FaceID e a Apple respondeu
                        switch result {
                        case .success(let autorizacao):
                            if let credencial = autorizacao.credential as? ASAuthorizationAppleIDCredential {
                                
                                // Pega os dados que a Apple devolveu
                                guard let nonce = vm.nonceAtual,
                                      let tokenDados = credencial.identityToken,
                                      let idToken = String(data: tokenDados, encoding: .utf8) else {
                                    print("Erro ao extrair tokens da Apple.")
                                    return
                                }
                                
                                // Manda para o Firebase criar a conta
                                vm.processarLoginApple(idToken: idToken, nonce: nonce, authManager: authManager)
                            }
                            
                        case .failure(let error):
                            print("Login com Apple falhou: \(error.localizedDescription)")
                        }
                    }
                    .signInWithAppleButtonStyle(.black)
                    .frame(height: 50)
                    .cornerRadius(12)
                    
                    Button {
                        vm.processarLoginGoogle(authManager: authManager)
                    } label: {
                        HStack(spacing: 4) {
                            Image("googleLogo")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 20, height: 20)
                            Text("Continuar com o Google")
                                .font(.system(size: 19, weight: .medium))
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.white)
                        .foregroundColor(.primary)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color(.systemGray4), lineWidth: 1)
                        )
                    }
                }
                .padding(.top, -24)
                .padding(.horizontal)
                
                // MARK: - 3. DIVISOR
                HStack {
                    Rectangle()
                        .frame(height: 1)
                        .foregroundColor(Color(.systemGray5))
                    Text("ou")
                        .font(.footnote)
                        .foregroundColor(.secondary)
                        .padding(.horizontal, 8)
                    Rectangle()
                        .frame(height: 1)
                        .foregroundColor(Color(.systemGray5))
                }
                .padding(.horizontal)
                
                // MARK: - 2. Formulário
                VStack(spacing: 16) {
                    
                    // Campo E-mail
                    VStack(alignment: .leading, spacing: 6) {
                        Text("E-mail")
                            .font(.footnote).bold()
                            .foregroundColor(.secondary)
                        TextField("Seu email", text: $vm.email)
                            .autocapitalization(.none)
                            .disableAutocorrection(true)
                            .padding()
                            .background(Color(.systemGroupedBackground))
                            .cornerRadius(12)
                    }
                    
                    // Campo Senha
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Crie uma senha")
                            .font(.footnote).bold()
                            .foregroundColor(.secondary)
                        SecureField("Mínimo 6 caracteres", text: $vm.senha)
                            .padding()
                            .background(Color(.systemGroupedBackground))
                            .cornerRadius(12)
                    }
                    
                    // Botão Principal de Cadastro
                    Button {
                        vm.criarConta(authManager: authManager)
                    } label: {
                        HStack {
                            if vm.carregando {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            } else {
                                Text("Criar minha conta")
                                    .font(.headline)
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(vm.email.isEmpty || vm.senha.isEmpty ? Color.gray.opacity(0.3) : Color(.teal))
                        .foregroundColor(.white)
                        .cornerRadius(12)
                    }
                    .disabled(vm.email.isEmpty || vm.senha.isEmpty || vm.carregando)
                    .padding(.top, 8)
                }
                .padding(.horizontal)
                
                Button {
                    dismiss()
                } label: {
                    HStack(spacing: 4) {
                        Text("Já tem uma conta?")
                            .foregroundColor(.secondary)
                        Text("Entre.")
                            .bold()
                            .foregroundColor(Color(.teal))
                    }
                    .font(.subheadline)
                }
                .padding(.top, 10)
                
                VStack(spacing: 4) {
                    Text("Ao criar sua conta, você concorda com os nossos")
                        .foregroundColor(.secondary)
                    
                    HStack(spacing: 4) {
                        Button("Termos de Serviço") { exibirTermos.toggle() }
                        Text("e")
                            .foregroundColor(.secondary)
                        Button("Política de Privacidade") { exibirPrivacidade.toggle() }
                    }
                    .bold()
                }
                .font(.caption2)
                .padding(.horizontal)
                .padding(.bottom, 20)
                
                
            }
        }
        .edgesIgnoringSafeArea(.top)
        
        .scrollDismissesKeyboard(.immediately)
        
        .navigationBarBackButtonHidden(true)
        
        .sheet(isPresented: $exibirTermos) {
            TermsOfServiceView().padding(.top, 24)
                .presentationDragIndicator(.visible)
        }
        .sheet(isPresented: $exibirPrivacidade) {
            PrivacyPolicyView().padding(.top, 24)
                .presentationDragIndicator(.visible)
        }
        
        // MARK: - ALERTA DE ERRO
        .alert(vm.tituloErro ?? "Erro", isPresented: $vm.exibirAlertaErro, actions: {
            Button("Ok", role: .cancel) {}
        }, message: {
            Text(vm.mensagemErro ?? "Ocorreu um erro inesperado. Tente novamente.")
        })
    }
    
    private func esconderTeclado() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

struct CreateAccountView_Previews: PreviewProvider {
    static var previews: some View {
        CreateAccountView()
            .environmentObject(AuthManager())
    }
}
