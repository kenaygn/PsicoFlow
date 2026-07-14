//
//  PsicoAppApp.swift
//  PsicoApp
//
//  Created by Kenay on 31/03/26.
//

import SwiftUI
import FirebaseCore

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        FirebaseApp.configure()
        return true
    }
}


@main
struct PsicoFlowApp: App {
    // Vai ter que sair pq quem vai carregar as sessoes vai ser um script no Firebase
    @Environment(\.scenePhase) var scenePhase
    
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    
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
