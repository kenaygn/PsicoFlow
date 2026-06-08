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

class SettingsViewModel: ObservableObject {
    
    @Published var ativarNotificacoes: Bool = true
    
    @Published var usarFaceID: Bool = UserDefaults.standard.bool(forKey: "usarFaceID") {
        didSet {
            UserDefaults.standard.set(usarFaceID, forKey: "usarFaceID")
        }
    }
    
    @Published var mostrarAlertaPermissaoFaceID: Bool = false
    
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
