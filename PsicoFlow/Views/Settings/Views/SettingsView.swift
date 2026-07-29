//
//  SettingsView.swift
//  PsicoFlow
//
//  Created by Kenay on 31/05/26.
//

import SwiftUI
import FirebaseAuth

struct SettingsView: View {
    
    @EnvironmentObject var authManager: AuthManager
    @StateObject private var viewModel = SettingsViewModel()
    
    let versaoApp = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "Desconhecida"
    
    @State private var mostrarAlertaSair = false
    @State private var mostrarAlertaExcluir = false
    @State private var mostrarModalUpgrade = false
    
    @State private var mostrarAlertaSeguranca = false
    @State private var mostrarErroGenerico = false
    @State private var mensagemErro = ""
    
    var body: some View {
        
        // Utilizamos o usuário da ViewModel, ou um fallback visual enquanto o Firebase devolve do cache (0.001s)
        let user = viewModel.currentUser ?? User(id: "", nome: "Carregando...", crp: "", premium: false, criadoEm: Date(), horaInicioExpediente: "07:00", horaFimExpediente: "22:00")
        
        NavigationStack {
            Form {
                
                // MARK: - 1. Assinatura e Planos
                if user.premium {
                    Section {
                        HStack {
                            Image(systemName: "checkmark.seal.fill")
                                .foregroundColor(.teal)
                                .font(.title2)
                            
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Psyes Pro")
                                    .font(.headline)
                                Text("Assinatura ativa")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                            Spacer()
                            
                            //                            Text("Gerenciar")
                            //                                .font(.subheadline)
                            //                                .foregroundColor(.teal)
                        }
                    }
                }else if user.nome == "Carregando..."{
                    
                } else {
                    PremiumCard(){
                        mostrarModalUpgrade = true
                    }
                    .listRowInsets(EdgeInsets())
                    .listRowBackground(Color.clear)
                    .padding(.vertical, 8)
                }
                
                // MARK: - 2. Conta do Usuário
                Section(header: Text("Sua Conta")) {
                    NavigationLink(destination: EditProfileView(authManager: authManager)) {
                        HStack(spacing: 12) {
                            VStack(alignment: .leading, spacing: 2) {
                                Text(user.nome)
                                    .font(.body)
                                Text("Editar informações e senha")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                        .padding(.vertical, 4)
                    }
                }
                
                // MARK: - 3. Preferências do Aplicativo
                Section(header: Text("Preferências")) {
                    Toggle(isOn: $viewModel.ativarNotificacoes) {
                        Text("Notificações de Sessões")
                    }
                    
                    Toggle(isOn: Binding(
                        get: { viewModel.usarFaceID },
                        set: { newValue in
                            viewModel.autenticarAtivacaoFaceID(ativar: newValue)
                        }
                    )) {
                        Text("Exigir Face ID")
                    }
                }
                
                // MARK: - 4. Suporte e Comunidade
                Section(header: Text("Suporte")) {
                    
                    NavigationLink(destination: HelpCenterView()) {
                        Text("Central de Ajuda")
                            .foregroundColor(.primary)
                    }
                    
                    Button(action: {
                        let email = "psyes.app@gmail.com"
                        let assunto = "Feedback / Reportar Erro - Psyes"
                        let corpo = "Olá equipe do Psyes!\n\n[Escreva aqui sua sugestão ou relate um erro]\n\n\n* Muito obrigado por compartilhar sua ideia ou nos ajudar a corrigir um problema! Seu feedback é essencial para continuarmos evoluindo o aplicativo. *\n\n---\nVersão do App: \(versaoApp)"
                        
                        let urlString = "mailto:\(email)?subject=\(assunto.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")&body=\(corpo.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")"
                        
                        if let url = URL(string: urlString) {
                            UIApplication.shared.open(url)
                        }
                    }) {
                        Text("Enviar Feedback")
                            .foregroundColor(.primary)
                    }
                }
                
                // MARK: - 5. Redes Sociais
                Section(header: Text("Redes Sociais")) {
                    
                    Button(action: {
                        let usuario = "kenaygn" //sem o @
                        let urlString = "https://www.instagram.com/\(usuario)"
                        
                        if let url = URL(string: urlString) {
                            UIApplication.shared.open(url)
                        }
                    }) {
                        HStack {
                            Text("Instagram")
                                .foregroundColor(.primary)
                        }
                    }
                    
                    Button(action: {
                        let usuario = "@psicoflowapp" //COM o @
                        let urlString = "https://www.tiktok.com/\(usuario)"
                        
                        if let url = URL(string: urlString) {
                            UIApplication.shared.open(url)
                        }
                    }) {
                        HStack {
                            Text("TikTok")
                                .foregroundColor(.primary)
                        }
                    }
                    
                    Button(action: {
                        let caminho = "in/kenay-gomes-nobre-509498339"
                        let urlString = "https://www.linkedin.com/\(caminho)"
                        
                        if let url = URL(string: urlString) {
                            UIApplication.shared.open(url)
                        }
                    }) {
                        HStack {
                            Text("LinkedIn")
                                .foregroundColor(.primary)
                        }
                    }
                }
                
                // MARK: - 6. Sobre e Documentos Legais
                Section(header: Text("Sobre")) {
                    NavigationLink(destination: TermsOfServiceView()) {
                        Text("Termos de Serviço")
                    }
                    NavigationLink(destination: PrivacyPolicyView()) {
                        Text("Política de Privacidade")
                    }
                    
                    HStack {
                        Text("Versão do Aplicativo")
                        Spacer()
                        Text(versaoApp)
                            .foregroundColor(.secondary)
                    }
                }
                
                // MARK: - 7. Área Sensível (Danger Zone)
                Section(header: Text("Área de Risco")) {
                    Button(action: {
                        mostrarAlertaSair = true
                    }) {
                        Text("Sair da Conta")
                            .foregroundColor(.red)
                    }
                    
                    Button(action: {
                        mostrarAlertaExcluir = true
                    }) {
                        Text("Excluir Conta")
                            .foregroundColor(.red)
                    }
                }
            }
            .navigationTitle("Ajustes")
            
            // MARK: - Eventos de Ciclo de Vida
            .onAppear {
                if let uid = authManager.usuarioID {
                    viewModel.carregarDadosUsuario(userId: uid)
                }
            }
            
            .alert("Permissão Necessária", isPresented: $viewModel.mostrarAlertaPermissaoFaceID) {
                Button("Cancelar", role: .cancel) { }
                
                Button("Abrir Ajustes") {
                    if let url = URL(string: UIApplication.openSettingsURLString) {
                        UIApplication.shared.open(url)
                    }
                }
            } message: {
                Text("O acesso ao Face ID foi negado anteriormente. Para utilizar este recurso, toque em 'Abrir Ajustes' e habilite o Face ID para o Psyes.")
            }
            
            .alert("Sair da Conta", isPresented: $mostrarAlertaSair) {
                Button("Cancelar", role: .cancel) { }
                
                Button("Sair", role: .destructive) {
                    UserDefaults.standard.set(false, forKey: "usarFaceID")
                    authManager.sairDaConta()
                }
            } message: {
                Text("Tem certeza de que deseja desconectar sua conta deste dispositivo?")
            }
            
            .alert("Excluir Conta", isPresented: $mostrarAlertaExcluir) {
                Button("Cancelar", role: .cancel) { }
                
                Button("Excluir Tudo", role: .destructive) {
                    Task {
                        do {
                            // Tenta deletar no Firebase primeiro
                            try await authManager.deletarConta()
                            
                            // Se der certo, remove o Face ID do UserDefaults
                            UserDefaults.standard.set(false, forKey: "usarFaceID")
                        } catch let error as NSError {
                            // 17014: requiresRecentLogin
                            // 17020: userTokenExpired
                            // 17004: invalidUserToken
                            let codigosDeSessaoInvalida = [
                                AuthErrorCode.requiresRecentLogin.rawValue,
                                AuthErrorCode.userTokenExpired.rawValue,
                                AuthErrorCode.invalidUserToken.rawValue
                            ]
                            
                            // Verifica se o erro faz parte dessa lista de segurança
                            if error.domain == AuthErrorDomain && codigosDeSessaoInvalida.contains(error.code) {
                                mostrarAlertaSeguranca = true
                            } else {
                                // Qualquer outro erro (falta de internet, etc)
                                mensagemErro = error.localizedDescription
                                mostrarErroGenerico = true
                            }
                        }
                    }
                }
            } message: {
                Text("Esta ação é irreversível. Todos os seus dados, configurações e informações vinculadas ao Psyes serão apagados permanentemente.")
            }
            
            .alert("Segurança da Conta", isPresented: $mostrarAlertaSeguranca) {
                Button("Cancelar", role: .cancel) { }
                
                Button("Fazer Logout Agora") {
                    UserDefaults.standard.set(false, forKey: "usarFaceID")
                    authManager.sairDaConta()
                }
            } message: {
                Text("Para excluir sua conta definitivamente, precisamos confirmar que é realmente você. Por favor, faça logout, entre no aplicativo novamente e repita esta ação.")
            }
            
            .alert("Erro ao Excluir", isPresented: $mostrarErroGenerico) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(mensagemErro)
            }
            
            .fullScreenCover(isPresented: $mostrarModalUpgrade) {
                UpgradePlanView(limiteAtingido: false)
            }
        }
    }
}

#Preview {
    SettingsView()
}
