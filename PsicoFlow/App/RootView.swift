//
//  RootView.swift
//  PsicoFlow
//
//  Created by Kenay on 02/06/26.
//

import SwiftUI

/// O Controlador de Tráfego Global do aplicativo.
/// Decide qual experiência o usuário deve ver com base no seu estado atual.
struct RootView: View {
    @Environment(\.scenePhase) var scenePhase
    
    @AppStorage("viuOnboarding") private var viuOnboarding: Bool = false
    
    @StateObject private var authManager = AuthManager()
    
    @AppStorage("usarFaceID") private var appExigeFaceID = false
    @State private var estaDesbloqueado = false
    
    private var precisaCompletarPerfil: Bool {
        let nomeVazio = authManager.usuarioAtual?.nome.trimmingCharacters(in: .whitespaces).isEmpty ?? true
        let crpVazio = authManager.usuarioAtual?.crp.trimmingCharacters(in: .whitespaces).isEmpty ?? true
        
        return nomeVazio || crpVazio
    }
    
    var body: some View {
        Group {
            if !viuOnboarding {
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
                    }
            }
        }
        .animation(.default, value: viuOnboarding)
        .animation(.default, value: authManager.usuarioLogado)
        .animation(.default, value: authManager.carregandoDados) // Animação do carregamento
        .animation(.default, value: precisaCompletarPerfil)
        .animation(.default, value: estaDesbloqueado)
        .onChange(of: scenePhase) { novaFase in
            // Quando o usuário minimiza o app (arrasta para cima) ou trava a tela do celular
            if novaFase == .background {
                // Se a segurança estiver ativada, nós retiramos o status de desbloqueado.
                if appExigeFaceID {
                    estaDesbloqueado = false
                }
            }
        }
    }
}

#Preview {
    RootView()
}
