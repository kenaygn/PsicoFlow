//
//  LoginView.swift
//  PsicoFlow
//
//  Created by Kenay on 14/07/26.
//

import SwiftUI

struct LoginView: View {
    @EnvironmentObject var authManager: AuthManager
    
    @StateObject private var vm = LoginViewModel()
    
    @State private var exibirTermos = false
    @State private var exibirPrivacidade = false
    
    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 24) {
                    
                    // MARK: - 1. LOGO (No topo)
                    VStack(spacing: 12) {
                        Image(systemName: "brain")
                            .font(.system(size: 60))
                            .foregroundColor(Color(.teal))
                            .padding(.top, 40)
                        
                        Text("Psyes")
                            .font(.system(.largeTitle, design: .rounded))
                            .foregroundStyle(Color.teal)
                            .bold()
                        
                        Text("Gestão inteligente para psicólogos[Mudar esse texto]")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    
                    // MARK: - 2. E-mail e Senha
                    VStack(spacing: 16) {
                        VStack(alignment: .leading, spacing: 6) {
                            Text("E-mail")
                                .font(.footnote).bold()
                                .foregroundColor(.secondary)
                            TextField("Seu email", text: $vm.email)
                                .keyboardType(.emailAddress)
                                .autocapitalization(.none)
                                .disableAutocorrection(true)
                                .padding()
                                .background(Color(.systemGroupedBackground))
                                .cornerRadius(12)
                        }
                        
                        VStack(alignment: .leading, spacing: 6) {
                            HStack{
                                Text("Senha")
                                    .font(.footnote).bold()
                                    .foregroundColor(.secondary)
                                Spacer()
                                Button(vm.tempoRestante > 0 ? "Reenviar em \(vm.tempoRestante)s" : "Esqueceu sua senha?") {
                                    vm.executarRecuperacaoDeSenha(authManager: authManager)
                                }
                                .font(.footnote)
                                .fontWeight(.medium)
                                .foregroundColor(vm.tempoRestante > 0 ? .gray : .teal)
                                .disabled(vm.tempoRestante > 0)
                            }
                            
                            SecureField("Sua senha", text: $vm.senha)
                                .padding()
                                .background(Color(.systemGroupedBackground))
                                .cornerRadius(12)
                        }
                        
                        Button {
                            vm.executarLogin(authManager: authManager)
                        } label: {
                            HStack {
                                if vm.carregando {
                                    ProgressView()
                                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                } else {
                                    Text("Entrar")
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
                    }
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
                    
                    // MARK: - 4. OPÇÕES SOCIAIS (Google & Apple)
                    VStack(spacing: 12) {
                        Button {
                            // Implementação futura
                        } label: {
                            HStack {
                                Image(systemName: "apple.logo")
                                Text("Continuar com a Apple")
                                    .font(.body).bold()
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.black)
                            .foregroundColor(.white)
                            .cornerRadius(12)
                        }
                        
                        Button {
                            // Implementação futura
                        } label: {
                            HStack {
                                Image("googleLogo")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 20, height: 20)
                                Text("Continuar com o Google")
                                    .font(.body).bold()
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
                    .padding(.horizontal)
                    
                    // MARK: - 5. CreateAccount
                    NavigationLink(destination: CreateAccountView()) {
                        HStack(spacing: 4) {
                            Text("Novo no Psyes?")
                                .foregroundColor(.secondary)
                            Text("Crie sua conta.")
                                .bold()
                                .foregroundColor(Color(.teal))
                        }
                        .font(.subheadline)
                    }
                    .padding(.top, 10)
                    
                    VStack(spacing: 4) {
                        Text("Ao entrar, você concorda com os nossos")
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
                    .padding(.top, 30)
                    .padding(.bottom, 20)
                    
                }
            }
            .onTapGesture {
                esconderTeclado()
            }
            .sheet(isPresented: $exibirTermos) {
                TermsOfServiceView().padding(.top, 24)
                    .presentationDragIndicator(.visible)
            }
            .sheet(isPresented: $exibirPrivacidade) {
                PrivacyPolicyView().padding(.top, 24)
                    .presentationDragIndicator(.visible)
            }
            
            // MARK: - ALERTAS
            .alert("E-mail Enviado", isPresented: $vm.mostrarAlertaRecuperacao, actions: {
                Button("OK", role: .cancel) { }
            }, message: {
                Text("Se este e-mail estiver cadastrado, você receberá um link para redefinir sua senha em instantes. Verifique sua caixa de entrada e spam.")
            })
            .alert(vm.tituloErro ?? "Erro ao entrar", isPresented: $vm.exibirAlertaErro, actions: {
                Button("Ok", role: .cancel) {}
            }, message: {
                Text(vm.mensagemErro ?? "Ocorreu um erro inesperado. Tente novamente.")
            })
        }
    }
    
    private func esconderTeclado() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
            .environmentObject(AuthManager())
    }
}
