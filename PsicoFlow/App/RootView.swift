//
//  RootView.swift
//  PsicoFlow
//
//  Created by Kenay on 02/06/26.
//

import SwiftUI
import Combine

/// O Controlador de Tráfego Global do aplicativo.
/// Decide qual experiência o usuário deve ver com base no seu estado atual.
struct RootView: View {
    @Environment(\.scenePhase) var scenePhase
    
    @StateObject private var networkMonitor = NetworkMonitor()
    
    @AppStorage("viuOnboarding") private var viuOnboarding: Bool = false
    
    @StateObject private var authManager = AuthManager.shared
    
    @StateObject private var storeManager = StoreManager()
    
    @AppStorage("usarFaceID") private var appExigeFaceID = false
    @State private var estaDesbloqueado = false
    
    private var precisaCompletarPerfil: Bool {
        let nomeVazio = authManager.usuarioAtual?.nome.trimmingCharacters(in: .whitespaces).isEmpty ?? true
        let crpVazio = authManager.usuarioAtual?.crp.trimmingCharacters(in: .whitespaces).isEmpty ?? true
        
        return nomeVazio || crpVazio
    }
    
    var body: some View {
        Group {
            if !networkMonitor.isConnected {
                NoInternetView()
                
            } else if !viuOnboarding {
                // ESTADO 1: Onboarding
                OnboardingView(viuOnboarding: $viuOnboarding)
                
            } else if !authManager.usuarioLogado {
                // ESTADO 2: Login
                LoginView()
                    .environmentObject(authManager)
                
            } else if authManager.carregandoDados {
                // Segura a tela em branco ou mostra um spinner para não piscar a interface
                VStack {
                    ProgressView()
                        .tint(.teal)
                        .scaleEffect(1.5)
                }
                
            } else if precisaCompletarPerfil {
                // ESTADO 3: Completar Perfil
                CompleteProfileView()
                    .environmentObject(authManager)
                
            } else if appExigeFaceID && !estaDesbloqueado {
                // ESTADO 4: Tela trancada com Face ID
                FaceIDBlockView(estaDesbloqueado: $estaDesbloqueado)
                
            } else {
                // ESTADO 5: Acesso Liberado ao App!
                MainTabView()
                    .environmentObject(authManager)
                    .onAppear {
                        estaDesbloqueado = true
                        
                        if let usuario = authManager.usuarioAtual {
                            Task {
                                await storeManager.sincronizarStatusComApple(usuarioAtual: usuario, userRepository: UserFirebaseRepository())
                            }
                        }
                    }
            }
        }
        .animation(.default, value: networkMonitor.isConnected)
        .animation(.default, value: viuOnboarding)
        .animation(.default, value: authManager.usuarioLogado)
        .animation(.default, value: authManager.carregandoDados)
        .animation(.default, value: precisaCompletarPerfil)
        .animation(.default, value: estaDesbloqueado)
        .onChange(of: scenePhase) { novaFase in
            if novaFase == .background {
                if appExigeFaceID {
                    estaDesbloqueado = false
                }
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("AtualizarStoreKit")).receive(on: RunLoop.main)) { _ in
            if let usuario = authManager.usuarioAtual {
                Task {
                    await storeManager.sincronizarStatusComApple(usuarioAtual: usuario, userRepository: UserFirebaseRepository())
                    
                    if let uid = authManager.usuarioID {
                        await authManager.buscarDadosDoUsuario(uid: uid)
                    }
                }
            }
        }
        .alert("Sua assinatura expirou", isPresented: $storeManager.assinaturaExpirou) {
            Button("Entendi", role: .cancel) { }
        } message: {
            Text("Seu plano Psyes Pro chegou ao fim. Algumas funcionalidades e pacientes excedentes foram bloqueados. Acesse os Ajustes para renovar e destravar seu acesso.")
        }
        
        .onChange(of: storeManager.assinaturaExpirou) { _ , expirou in
            if expirou {
                authManager.usuarioAtual?.premium = false
            }
        }
    }
}

#Preview {
    RootView()
}
