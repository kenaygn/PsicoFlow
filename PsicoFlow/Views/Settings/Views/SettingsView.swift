//
//  SettingsView.swift
//  PsicoFlow
//
//  Created by Kenay on 31/05/26.
//

import SwiftUI

struct SettingsView: View {
    
    @StateObject private var viewModel = SettingsViewModel()
    
    let versaoApp = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "Desconhecida"
    
    var body: some View {
        NavigationStack {
            Form {
                
                // MARK: - 1. Assinatura e Planos
                if viewModel.currentUser.premium {
                    Section {
                        HStack {
                            Image(systemName: "checkmark.seal.fill")
                                .foregroundColor(.cyan)
                                .font(.title2)
                            
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Plano PsicoFlow Pro")
                                    .font(.headline)
                                Text("Assinatura ativa")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                            Spacer()
                            
                            Text("Gerenciar")
                                .font(.subheadline)
                                .foregroundColor(.cyan)
                        }
                    }
                } else {
                    PremiumCard()
                        .listRowInsets(EdgeInsets())
                        .listRowBackground(Color.clear)
                        .padding(.vertical, 8)
                }
                
                // MARK: - 2. Conta do Usuário
                Section(header: Text("Sua Conta")) {
                    NavigationLink(destination: Text("Tela de Edição de Perfil")) {
                        HStack(spacing: 12) {
                            VStack(alignment: .leading, spacing: 2) {
                                Text(viewModel.currentUser.nome)
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
                    
                    //Note: mudar o nome do app
                    Button(action: {
                        let email = "kenaysocial@gmail.com"
                        let assunto = "Feedback / Reportar Erro - PsicoFlow"
                        let corpo = "Olá equipe do PsicoFlow!\n\n[Escreva aqui sua sugestão ou relate um erro]\n\n\n* Muito obrigado por compartilhar sua ideia ou nos ajudar a corrigir um problema! Seu feedback é essencial para continuarmos evoluindo o aplicativo. *\n\n---\nVersão do App: \(versaoApp)"
                        
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
                    
                    // Botão do Instagram
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
                    
                    // Botão do TikTok
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
                    
                    // Botão do LinkedIn
                    Button(action: {
                        // empresa: "company/nome"
                        // perfil pessoal: "in/nome"
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
                    NavigationLink(destination: Text("Política de Privacidade")) {
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
                        viewModel.sairDaConta()
                    }) {
                        Text("Sair da Conta")
                            .foregroundColor(.red)
                    }
                    
                    Button(action: {
                        viewModel.deletarConta()
                    }) {
                        Text("Excluir Conta")
                            .foregroundColor(.red)
                    }
                }
            }
            .navigationTitle("Ajustes")
            .alert("Permissão Necessária", isPresented: $viewModel.mostrarAlertaPermissaoFaceID) {
                Button("Cancelar", role: .cancel) { }
                
                Button("Abrir Ajustes") {
                    if let url = URL(string: UIApplication.openSettingsURLString) {
                        UIApplication.shared.open(url)
                    }
                }
            } message: {
                Text("O acesso ao Face ID foi negado anteriormente. Para utilizar este recurso, toque em 'Abrir Ajustes' e habilite o Face ID para o PsicoFlow.")
            }
        }
    }
}



#Preview {
    SettingsView()
}
