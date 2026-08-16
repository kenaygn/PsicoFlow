//
//  PushToStartManager.swift
//  PsicoFlow
//
//  Created by Kenay on 14/08/26.
//

import Foundation
import ActivityKit
import FirebaseFirestore
import FirebaseAuth

class PushToStartManager {
    static let shared = PushToStartManager()
    
    func iniciarMonitoramento() {
        Task {
            // A API exige iOS 17.2+
            if #available(iOS 17.2, *) {
                for await tokenData in Activity<SessionActivityAttributes>.pushToStartTokenUpdates {
                    let token = tokenData.map { String(format: "%02x", $0) }.joined()
                    print("Token de Push-to-Start gerado: \(token)")
                    salvarTokenNoFirestore(token: token)
                }
            }
        }
    }
    
    private func salvarTokenNoFirestore(token: String) {
        // Usa o usuário atualmente logado para salvar no banco de dados correto
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        let db = Firestore.firestore()
        db.collection("users").document(uid).setData([
            "liveActivityToken": token,
            "liveActivityTokenAtualizadoEm": FieldValue.serverTimestamp()
        ], merge: true)
    }
    
    func iniciarMonitoramentoDeEncerramento() {
        Task {
            if #available(iOS 16.2, *) {
                // Fica escutando qualquer Live Activity que nasça no app
                for await activity in Activity<SessionActivityAttributes>.activityUpdates {
                    Task {
                        // Assim que ela nasce, gera o Token de Atualização/Encerramento
                        for await tokenData in activity.pushTokenUpdates {
                            let token = tokenData.map { String(format: "%02x", $0) }.joined()
                            print("Token de Encerramento gerado: \(token)")
                            salvarTokenDeEncerramentoNoFirestore(token: token)
                        }
                    }
                }
            }
        }
    }
    
    private func salvarTokenDeEncerramentoNoFirestore(token: String) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        let db = Firestore.firestore()
        db.collection("users").document(uid).setData([
            "liveActivityUpdateToken": token
        ], merge: true)
    }
}
