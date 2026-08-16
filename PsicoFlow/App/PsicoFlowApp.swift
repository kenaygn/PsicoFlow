//
//  PsicoAppApp.swift
//  PsicoApp
//
//  Created by Kenay on 31/03/26.
//

import SwiftUI
import FirebaseCore
import FirebaseAuth
import FirebaseMessaging
import FirebaseFirestore

class AppDelegate: NSObject, UIApplicationDelegate, UNUserNotificationCenterDelegate, MessagingDelegate {
    
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        FirebaseApp.configure()
        
        // Configura o interceptador de Notificações do Firebase
        Messaging.messaging().delegate = self
        UNUserNotificationCenter.current().delegate = self
        application.registerForRemoteNotifications()
        
        // Inicia o monitoramento das Live Activities
        PushToStartManager.shared.iniciarMonitoramento()
        PushToStartManager.shared.iniciarMonitoramentoDeEncerramento()
        
        return true
    }

    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        guard let token = fcmToken, let uid = Auth.auth().currentUser?.uid else { return }
        let db = Firestore.firestore()
        db.collection("users").document(uid).setData([
            "fcmToken": token
        ], merge: true)
    }

    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        
        print("App acordou no background! O PushToStartManager já está pescando o token...")
        
        // Avisa ao iOS que o app terminou o trabalho rápido
        completionHandler(.newData)
    }
}

@main
struct PsicoFlowApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    
    var body: some Scene {
        WindowGroup {
            RootView()
                .preferredColorScheme(.light)
        }
    }
}
