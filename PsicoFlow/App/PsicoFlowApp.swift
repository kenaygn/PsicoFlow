//
//  PsicoAppApp.swift
//  PsicoApp
//
//  Created by Kenay on 31/03/26.
//

import SwiftUI
import FirebaseCore
import FirebaseAuth // Adicionado para acessar a sessão do usuário logado

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        FirebaseApp.configure()
        return true
    }
}

@main
struct PsicoFlowApp: App {
    // TODO: Vai ter que sair pq quem vai carregar as sessoes vai ser um script no Firebase
    @Environment(\.scenePhase) var scenePhase
    
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    
    var body: some Scene {
        WindowGroup {
            RootView()
                .preferredColorScheme(.light)
        }
        
        // TODO: Remover bloco onChange futuramente quando a automação for para o backend
        .onChange(of: scenePhase) { novaFase in
            if novaFase == .active {
                // Recupera o ID do usuário ativo diretamente do Firebase
                if let uid = Auth.auth().currentUser?.uid {
                    
                    // Se a sua função runStartupChecks foi refatorada para ser 'async',
                    // basta envolver a linha abaixo em uma Task { await ... }
                    SystemUpdateManager.shared.runStartupChecks(userId: uid)
                    
                }
            }
        }
    }
}
