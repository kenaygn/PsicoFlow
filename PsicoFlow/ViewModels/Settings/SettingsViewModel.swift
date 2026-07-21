//
//  SettingsViewModel.swift
//  PsicoFlow
//
//  Created by Kenay on 31/05/26.
//

import Foundation
import SwiftUI
import Combine
import LocalAuthentication
import FirebaseFirestore // Necessário para o ListenerRegistration

class SettingsViewModel: ObservableObject {
    
    // MARK: - Dados do Usuário (Offline-First)
    @Published var currentUser: User?
    private var userListener: ListenerRegistration?
    private let userRepository: UserRepositoryProtocol
    
    // MARK: - Configurações Locais
    @Published var ativarNotificacoes: Bool = true
    
    @Published var usarFaceID: Bool = UserDefaults.standard.bool(forKey: "usarFaceID") {
        didSet {
            UserDefaults.standard.set(usarFaceID, forKey: "usarFaceID")
        }
    }
    
    @Published var mostrarAlertaPermissaoFaceID: Bool = false
    
    init(userRepository: UserRepositoryProtocol = UserFirebaseRepository()) {
        self.userRepository = userRepository
    }
    
    deinit {
        userListener?.remove()
    }
    
    // MARK: - Carregamento Offline-First
    func carregarDadosUsuario(userId: String) {
        guard !userId.isEmpty else { return }
        
        userListener?.remove()
        
        if let firebaseRepo = userRepository as? UserFirebaseRepository {
            userListener = firebaseRepo.escutarUsuario(uid: userId) { [weak self] usuarioAtualizado in
                guard let self = self else { return }
                
                withAnimation(.easeInOut(duration: 0.3)) {
                    self.currentUser = usuarioAtualizado
                }
            }
        }
    }
    
    // MARK: - Lógica do Face ID
    func autenticarAtivacaoFaceID(ativar: Bool) {
        guard ativar else {
            self.usarFaceID = false
            return
        }
        
        let context = LAContext()
        var error: NSError?
        
        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            let reason = "Autentique para habilitar o bloqueio por Face ID."
            
            context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason) { success, authError in
                DispatchQueue.main.async {
                    if success {
                        self.usarFaceID = true
                    } else {
                        
                        self.usarFaceID = false
                    }
                }
            }
        } else {
            DispatchQueue.main.async {
                self.usarFaceID = false
                
                self.mostrarAlertaPermissaoFaceID = true
            }
        }
    }
}
