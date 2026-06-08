//
//  AuthManager.swift
//  PsicoFlow
//
//  Created by Kenay on 02/06/26.
//

import Foundation
import Combine

class AuthManager: ObservableObject {
    // Se for 'nil', o app entende que ninguém está logado e joga para o RootView (Login).
    @Published var currentUser: User?
    
    // Propriedade computada que mantém a compatibilidade perfeita com o seu RootView atual
    var usuarioLogado: Bool {
        currentUser != nil
    }
    
    init() {
        logarMock()
    }
    
    // MARK: - Funções de Autenticação (Mock para o Firebase)
    func logarMock() {
        self.currentUser = User(
            id: "firebase_mock_uid_123",
            nome: "Dr. Psicólogo",
            email: "contato@psicoflow.com.br",
            crp: "06/123456",
            premium: false,
            criadoEm: Date()
        )
    }
    
    func sairDaConta() {
        print("🚪 Fazendo logout do Mock...")
        // Futuramente: try? Auth.auth().signOut()
        self.currentUser = nil // Isso avisa o RootView para fechar o MainTabView
    }
    
    func deletarConta() {
        print("⚠️ Deletando conta do Mock...")
        // Futuramente: Auth.auth().currentUser?.delete()
        self.currentUser = nil
    }
}
