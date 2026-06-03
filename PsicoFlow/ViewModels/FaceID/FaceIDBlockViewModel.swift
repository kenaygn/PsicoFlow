//
//  FaceIDBlockViewModel.swift
//  PsicoFlow
//
//  Created by Kenay on 03/06/26.
//

import Foundation
import LocalAuthentication
import Combine

class FaceIDBlockViewModel: ObservableObject {
    
    /// Executa a tentativa de autenticação biométrica ou por senha.
    /// - Parameter completion: Retorna `true` se a autenticação foi um sucesso ou ignorada por falta de hardware, e `false` se falhou/cancelou.
    func autenticarParaEntrar(completion: @escaping (Bool) -> Void) {
        let context = LAContext()
        var error: NSError?
        
        // Avalia se o dispositivo possui autenticação configurada (Rosto, Dedo ou Senha)
        if context.canEvaluatePolicy(.deviceOwnerAuthentication, error: &error) {
            let motivo = "Desbloqueie o aplicativo para continuar."
            
            context.evaluatePolicy(.deviceOwnerAuthentication, localizedReason: motivo) { sucesso, _ in
                // Retorna o resultado para a Main Thread para que a View possa atualizar a UI
                DispatchQueue.main.async {
                    completion(sucesso)
                }
            }
        } else {
            // Dispositivo sem senha e sem biometria: libera por padrão para evitar que o usuário fique trancado
            DispatchQueue.main.async {
                completion(true)
            }
        }
    }
}
