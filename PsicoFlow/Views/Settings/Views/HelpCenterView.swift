//
//  HelpCenterView.swift
//  PsicoFlow
//
//  Created by Kenay on 04/06/26.
//

import SwiftUI

struct HelpCenterView: View {
    var body: some View {
        List {
            // MARK: - FAQ (Dúvidas Frequentes)
            Section(header: Text("Dúvidas Frequentes")) {
                
                DisclosureGroup("Como mudo minha senha?") {
                    Text("Para alterar sua senha, retorne à tela principal de Ajustes, clique no seu nome em 'Sua Conta' e selecione a opção de editar informações e senha.")
                        .font(.callout)
                        .foregroundColor(.secondary)
                        .padding(.vertical, 4)
                }
                
                DisclosureGroup("Como cancelo a assinatura?") {
                    Text("O cancelamento é feito com segurança pelo próprio sistema da Apple. Vá no aplicativo 'Ajustes' do seu iPhone > Toque no seu Nome (ID Apple) > Assinaturas > PsicoFlow > Cancelar Assinatura.")
                        .font(.callout)
                        .foregroundColor(.secondary)
                        .padding(.vertical, 4)
                }
                
                DisclosureGroup("Como adiciono um novo paciente?") {
                    Text("Vá até a aba 'Pacientes' no menu inferior e toque no ícone de '+' no canto superior direito da tela. Preencha os dados básicos e salve para criar o prontuário.")
                        .font(.callout)
                        .foregroundColor(.secondary)
                        .padding(.vertical, 4)
                }
                
                DisclosureGroup("Meus dados e de pacientes estão seguros?") {
                    Text("Sim. Utilizamos criptografia e os dados ficam salvos de forma segura. Para evitar acessos físicos indesejados ao seu celular, recomendamos ativar o bloqueio por 'Face ID' na tela de Ajustes do aplicativo.")
                        .font(.callout)
                        .foregroundColor(.secondary)
                        .padding(.vertical, 4)
                }
            }
            
            // MARK: - Contato Direto
            Section {
                VStack(alignment: .center, spacing: 16) {
                    Text("Não encontrou o que procurava?")
                        .font(.subheadline)
                        .foregroundColor(.primary)
                    
                    Button(action: {
                        enviarEmailSuporte()
                    }) {
                        HStack {
                            Image(systemName: "envelope.fill")
                            Text("Entrar em contato com o suporte")
                                .fontWeight(.bold)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(Color.cyan)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                    }
                }
                .padding(.vertical, 12)
                .frame(maxWidth: .infinity)
            }
            .listRowBackground(Color.clear)
            .listRowInsets(EdgeInsets())
        }
        .navigationTitle("Central de Ajuda")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    // MARK: - Função de Deep Link para E-mail
    //Note: mudar o nome do app
    private func enviarEmailSuporte() {
        let email = "kenaysocial@gmail.com"
        let assunto = "Ajuda com o PsicoFlow"
        let versaoApp = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "Desconhecida"
        
        let corpo = "Olá equipe do PsicoFlow!\n\n[Escreva aqui com o que podemos te ajudar]\n\n\n* Fique tranquilo, nossa equipe vai analisar sua mensagem e responderemos o mais rápido possível! *\n\n---\nVersão do App: \(versaoApp)"
        
        let urlString = "mailto:\(email)?subject=\(assunto.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")&body=\(corpo.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")"
        
        if let url = URL(string: urlString) {
            UIApplication.shared.open(url)
        }
    }
}

#Preview {
    NavigationStack {
        HelpCenterView()
    }
}
