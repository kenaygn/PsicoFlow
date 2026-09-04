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
    
    @State private var exibindoSplash: Bool = true
    
    private var precisaCompletarPerfil: Bool {
        let nomeVazio = authManager.currentUser?.name.trimmingCharacters(in: .whitespaces).isEmpty ?? true
        let crpVazio = authManager.currentUser?.crp.trimmingCharacters(in: .whitespaces).isEmpty ?? true
        
        return nomeVazio || crpVazio
    }
    
    var body: some View {
        Group {
            if exibindoSplash || authManager.loadingData {
                PsyesLoadingView()
                    .transition(.opacity)
                    .onAppear {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                            withAnimation(.easeInOut) {
                                exibindoSplash = false
                            }
                        }
                    }
                
            } else if !networkMonitor.isConnected {
                NoInternetView()
                
            } else if !viuOnboarding {
                OnboardingView(viuOnboarding: $viuOnboarding)
                
            } else if !authManager.userLoggedIn {
                LoginView()
                    .environmentObject(authManager)
                
            } else if precisaCompletarPerfil {
                CompleteProfileView()
                    .environmentObject(authManager)
                
            } else if appExigeFaceID && !estaDesbloqueado {
                FaceIDBlockView(estaDesbloqueado: $estaDesbloqueado)
                
            } else {
                MainTabView()
                    .environmentObject(authManager)
                    .onAppear {
                        estaDesbloqueado = true
                        
                        if let usuario = authManager.currentUser {
                            Task {
                                await storeManager.syncStatusWithApple(currentUser: usuario, userRepository: UserFirebaseRepository())
                            }
                        }
                    }
            }
        }
        .animation(.default, value: exibindoSplash)
        .animation(.default, value: networkMonitor.isConnected)
        .animation(.default, value: viuOnboarding)
        .animation(.default, value: authManager.userLoggedIn)
        .animation(.default, value: authManager.loadingData)
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
            if let usuario = authManager.currentUser {
                Task {
                    await storeManager.syncStatusWithApple(currentUser: usuario, userRepository: UserFirebaseRepository())
                    
                    if let uid = authManager.userID {
                        await authManager.fetchUserData(uid: uid)
                    }
                }
            }
        }
        .alert("Sua assinatura expirou", isPresented: $storeManager.subscriptionExpired) {
            Button("Entendi", role: .cancel) { }
        } message: {
            Text("Seu plano Psyes Pro chegou ao fim. Algumas funcionalidades e pacientes excedentes foram bloqueados. Acesse os Ajustes para renovar e destravar seu acesso.")
        }
        
        .onChange(of: storeManager.subscriptionExpired) { _ , expirou in
            if expirou {
                authManager.currentUser?.premium = false
            }
        }
    }
}

#Preview {
    RootView()
}
