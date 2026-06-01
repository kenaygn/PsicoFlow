//
//  SettingsViewModel.swift
//  PsicoFlow
//
//  Created by Kenay on 31/05/26.
//

import Foundation
import SwiftUI
import Combine

class SettingsViewModel: ObservableObject {
    
    // Utilizando a estrutura User nativa do sistema
    @Published var currentUser: User = User(
        id: "user_123",
        nome: "Dr. Psicólogo",
        email: "contato@psicoflow.com.br",
        crp: "06/123456",
        premium: false, // Mude para true para ver o layout de assinante
        criadoEm: Date()
    )
    
    // Toggles de Preferência
    @Published var usarFaceID: Bool = false
    @Published var ativarNotificacoes: Bool = true
    
    // Ações Sensíveis
    func sairDaConta() {
        print("🚪 Fazendo logout...")
    }
    
    func deletarConta() {
        print("⚠️ Deletando conta permanentemente...")
    }
}
