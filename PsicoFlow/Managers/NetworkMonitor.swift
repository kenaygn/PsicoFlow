//
//  NetworkMonitor.swift
//  PsicoFlow
//
//  Created by Kenay on 28/07/26.
//

import Foundation
import Network
import SwiftUI
import Combine

/// Classe responsável por monitorar o status da conexão de internet em tempo real.
class NetworkMonitor: ObservableObject {
    private let networkMonitor = NWPathMonitor()
    private let workerQueue = DispatchQueue(label: "NetworkMonitorQueue")
    
    @Published var isConnected = true
    
    init() {
        networkMonitor.pathUpdateHandler = { path in
            // Precisamos atualizar a variável @Published na Main Thread para refletir na UI
            DispatchQueue.main.async {
                self.isConnected = path.status == .satisfied
            }
        }
        networkMonitor.start(queue: workerQueue)
    }
}
