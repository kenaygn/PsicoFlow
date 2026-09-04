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
import FirebaseFirestore
import UserNotifications

class SettingsViewModel: ObservableObject {
    
    @Published var currentUser: User?
    private var userListener: ListenerRegistration?
    private let userRepository: UserRepositoryProtocol
    
    @Published var ativarNotificacoes: Bool = true
    @Published var mostrarAlertaNotificacoes: Bool = false
    
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
    
    func carregarDadosUsuario(userId: String) {
        guard !userId.isEmpty else { return }
        
        userListener?.remove()
        
        if let firebaseRepo = userRepository as? UserFirebaseRepository {
            userListener = firebaseRepo.listenToUsers(uid: userId) { [weak self] usuarioAtualizado in
                guard let self = self else { return }
                
                withAnimation(.easeInOut(duration: 0.3)) {
                    self.currentUser = usuarioAtualizado
                }
            }
        }
    }
    
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
    
    
    func verificarStatusNotificacoes() {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            DispatchQueue.main.async {
                self.ativarNotificacoes = (settings.authorizationStatus == .authorized || settings.authorizationStatus == .provisional)
            }
        }
    }
    
    func solicitarMudancaDeNotificacao(ativar: Bool) {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            DispatchQueue.main.async {
                if settings.authorizationStatus == .notDetermined {
                    // Primeira vez que o app pede notificação
                    UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, _ in
                        DispatchQueue.main.async {
                            self.ativarNotificacoes = granted
                            if granted {
                                UIApplication.shared.registerForRemoteNotifications()
                            }
                        }
                    }
                } else {
                    // O usuário já negou ou aceitou antes. Só dá pra mudar nos Ajustes do iPhone.
                    // Reverte o Toggle para o status real do sistema e mostra o alerta.
                    self.ativarNotificacoes = (settings.authorizationStatus == .authorized)
                    self.mostrarAlertaNotificacoes = true
                }
            }
        }
    }
    
}
