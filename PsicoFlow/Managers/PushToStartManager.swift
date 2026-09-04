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
    
    func startMonitoring() {
        Task {
            if #available(iOS 17.2, *) {
                for await tokenData in Activity<SessionActivityAttributes>.pushToStartTokenUpdates {
                    let token = tokenData.map { String(format: "%02x", $0) }.joined()
                    print("Push-to-Start token generated: \(token)")
                    saveTokenToFirestore(token: token)
                }
            }
        }
    }
    
    private func saveTokenToFirestore(token: String) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        let db = Firestore.firestore()
        db.collection("users").document(uid).setData([
            "liveActivityToken": token,
            "liveActivityTokenUpdatedAt": FieldValue.serverTimestamp()
        ], merge: true)
    }
    
    func startEndMonitoring() {
        Task {
            if #available(iOS 16.2, *) {
                for await activity in Activity<SessionActivityAttributes>.activityUpdates {
                    Task {
                        for await tokenData in activity.pushTokenUpdates {
                            let token = tokenData.map { String(format: "%02x", $0) }.joined()
                            print("End token generated: \(token)")
                            saveEndTokenToFirestore(token: token)
                        }
                    }
                }
            }
        }
    }
    
    private func saveEndTokenToFirestore(token: String) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        let db = Firestore.firestore()
        db.collection("users").document(uid).setData([
            "liveActivityUpdateToken": token
        ], merge: true)
    }
}
