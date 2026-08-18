//
//  SettingsView.swift
//  PsicoFlow
//
//  Created by Kenay on 31/05/26.
//

import SwiftUI
import FirebaseAuth

import ActivityKit

struct SettingsView: View {
    
    @EnvironmentObject var authManager: AuthManager
    @StateObject private var viewModel = SettingsViewModel()
    
    @Environment(\.scenePhase) var scenePhase
    
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
                    Toggle(isOn: Binding(
                        get: { viewModel.ativarNotificacoes },
                        set: { newValue in
                            viewModel.solicitarMudancaDeNotificacao(ativar: newValue)
                        }
                    )) {
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
                
                // --------------------------------------------
                //Teste Live Activity
                Section(header: Text("Teste Rápido - Live Activity")) {
                    
                    // Botão de Iniciar
                    Button(action: {
                        guard ActivityAuthorizationInfo().areActivitiesEnabled else {
                            print("Live Activities estão desativadas.")
                            return
                        }
                        
                        let atributos = SessionActivityAttributes(
                            nomePaciente: "Ana Carolina",
                            modalidade: "Presencial",
                            isFixa: true,
                            horaInicio: "14:00"
                        )
                        
                        let estadoInicial = SessionActivityAttributes.ContentState(
                            statusMensagem: "Tudo pronto para o atendimento."
                        )
                        
                        do {
                            if #available(iOS 16.2, *) {
                                let conteudo = ActivityContent(state: estadoInicial, staleDate: nil)
                                _ = try Activity.request(attributes: atributos, content: conteudo)
                            } else {
                                _ = try Activity.request(attributes: atributos, contentState: estadoInicial)
                            }
                            print("Live Activity iniciada!")
                        } catch {
                            print("Erro ao iniciar: \(error.localizedDescription)")
                        }
                    }) {
                        HStack {
                            Image(systemName: "play.circle.fill")
                            Text("Iniciar Live Activity")
                        }
                        .foregroundColor(.teal)
                    }
                    
                    // Botão de Parar
                    Button(action: {
                        Task {
                            let estadoFinal = SessionActivityAttributes.ContentState(statusMensagem: "Sessão concluída.")
                            
                            // Procura todas as atividades do Psyes rodando e mata todas
                            for atividade in Activity<SessionActivityAttributes>.activities {
                                if #available(iOS 16.2, *) {
                                    let conteudoFinal = ActivityContent(state: estadoFinal, staleDate: nil)
                                    await atividade.end(conteudoFinal, dismissalPolicy: .immediate)
                                } else {
                                    await atividade.end(using: estadoFinal, dismissalPolicy: .immediate)
                                }
                            }
                            print("Live Activity encerrada!")
                        }
                    }) {
                        HStack {
                            Image(systemName: "stop.circle.fill")
                            Text("Encerrar Live Activity")
                        }
                        .foregroundColor(.red)
                    }
                }
                // --------------------------------------------
            }
            .navigationTitle("Ajustes")
            
            // MARK: - Eventos de Ciclo de Vida
            .onAppear {
                viewModel.verificarStatusNotificacoes()
                if let uid = authManager.usuarioID {
                    viewModel.carregarDadosUsuario(userId: uid)
                }
            }
            .onChange(of: scenePhase) { _, newPhase in
                if newPhase == .active {
                    // Se o usuário foi nos Ajustes e voltou, atualiza o botão automaticamente
                    viewModel.verificarStatusNotificacoes()
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
                    
                    if let lastSignIn = Auth.auth().currentUser?.metadata.lastSignInDate {
                        let tempoDesdeLogin = Date().timeIntervalSince(lastSignIn)
                        
                        if tempoDesdeLogin > 300 {
                            mostrarAlertaSeguranca = true
                            return
                        }
                    }
                    
                    Task {
                        do {
                            try await authManager.deletarConta()
                            UserDefaults.standard.set(false, forKey: "usarFaceID")
                            authManager.sairDaConta()
                            
                        } catch let error as NSError {
                            let codigosDeSessaoInvalida = [
                                AuthErrorCode.requiresRecentLogin.rawValue,
                                AuthErrorCode.userTokenExpired.rawValue,
                                AuthErrorCode.invalidUserToken.rawValue
                            ]
                            
                            if error.domain == AuthErrorDomain && codigosDeSessaoInvalida.contains(error.code) {
                                mostrarAlertaSeguranca = true
                            } else {
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
                Text("Por medidas de segurança, a exclusão definitiva da conta exige um login recente. Seus dados estão seguros e NÃO foram apagados. Por favor, faça logout, entre novamente e repita a ação.")
            }
            
            .alert("Erro ao Excluir", isPresented: $mostrarErroGenerico) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(mensagemErro)
            }
            
            .alert("Ajustes do Sistema", isPresented: $viewModel.mostrarAlertaNotificacoes) {
                Button("Cancelar", role: .cancel) { }
                
                Button("Abrir Ajustes") {
                    if let url = URL(string: UIApplication.openSettingsURLString) {
                        UIApplication.shared.open(url)
                    }
                }
            } message: {
                Text("Para ativar ou desativar as notificações do Psyes, você precisa alterar esta permissão nos Ajustes do seu iPhone.")
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
