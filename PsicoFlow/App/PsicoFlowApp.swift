//
//  PsicoAppApp.swift
//  PsicoApp
//
//  Created by Kenay on 31/03/26.
//

import SwiftUI

@main
struct PsicoFlowApp: App {
    // Vai ter que sair pq quem vai carregar as sessoes vai ser um script no Firebase
    @Environment(\.scenePhase) var scenePhase
    
    var body: some Scene {
        WindowGroup {
            RootView()
                .preferredColorScheme(.light)
        }
        // Vai ter que sair pq quem vai carregar as sessoes vai ser um script no Firebase
        .onChange(of: scenePhase) { novaFase in
            if novaFase == .active {
                 SystemUpdateManager.shared.runStartupChecks()
            }
        }
    }
}
