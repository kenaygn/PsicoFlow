//
//  PsicoAppApp.swift
//  PsicoApp
//
//  Created by Kenay on 31/03/26.
//

import SwiftUI

@main
struct PsicoFlowApp: App {
    var body: some Scene {
        WindowGroup {
            MainTabView()
                .preferredColorScheme(.light)
        }
    }
}
