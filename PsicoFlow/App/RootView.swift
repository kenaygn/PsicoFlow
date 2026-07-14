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
    
    var body: some View {
        Group {
            if !viuOnboarding {
                // ESTADO 1: Onboarding
                
                OnboardingView(viuOnboarding: $viuOnboarding)
                
            } else if !authManager.usuarioLogado {
                // ESTADO 2: Login
                
                 LoginView()
                    .environmentObject(authManager)
                                
            } else if appExigeFaceID && !estaDesbloqueado {
                // ESTADO 3: Tela trancada com Face ID
                FaceIDBlockView(estaDesbloqueado: $estaDesbloqueado)
                
            } else {
                // ESTADO 4: Acesso Liberado ao App!
                MainTabView()
                // Injetamos o AuthManager caso alguma tela lá dentro queira fazer "Logout"
                    .environmentObject(authManager)
                    .onAppear {
                        estaDesbloqueado = true
                    }
            }
        }
        .animation(.default, value: viuOnboarding)
        .animation(.default, value: authManager.usuarioLogado)
        .animation(.default, value: estaDesbloqueado)
        .onChange(of: scenePhase) { novaFase in
            // Quando o usuário minimiza o app (arrasta para cima) ou trava a tela do celular
            if novaFase == .background {
                // Se a segurança estiver ativada, nós retiramos o status de desbloqueado.
                // Quando o usuário voltar, ele cairá no "ESTADO 3" e a biometria será exigida novamente!
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
