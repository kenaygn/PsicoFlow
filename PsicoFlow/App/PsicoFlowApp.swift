//
//  PsicoAppApp.swift
//  PsicoApp
//
//  Created by Kenay on 31/03/26.
//

import SwiftUI

@main
struct PsicoFlowApp: App {
    
    @Environment(\.scenePhase) var scenePhase
    
    var body: some Scene {
        WindowGroup {
            MainTabView()
                .preferredColorScheme(.light)
        }
        // Dispara toda vez que o usuário abre ou volta para o aplicativo
        .onChange(of: scenePhase) { novaFase in
            if novaFase == .active {
                SystemUpdateManager.shared.runStartupChecks()
            }
        }
    }
}
