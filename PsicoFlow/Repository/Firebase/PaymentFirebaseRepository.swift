//
//  PaymentFirebaseRepository.swift
//  PsicoFlow
//
//  Created by Kenay on 17/07/26.
//

import Foundation
import FirebaseFirestore

class PaymentFirebaseRepository: PaymentRepositoryProtocol {
    private let db = Firestore.firestore()
    
    private func collection(userId: String) -> CollectionReference {
        return db.collection("users").document(userId).collection("payments")
    }
    
    // MARK: - Funções de Fetch Antigas (Mantidas para compatibilidade)
    func fetchPagamentos(userId: String) async throws -> [MonthlyPayment] {
        let snapshot = try await collection(userId: userId).getDocuments()
        return snapshot.documents.compactMap { try? $0.data(as: MonthlyPayment.self) }
    }
    
    func fetchPagamentos(paraPacienteID pacienteID: String, userId: String) async throws -> [MonthlyPayment] {
        let snapshot = try await collection(userId: userId)
            .whereField("pacienteID", isEqualTo: pacienteID)
            .getDocuments()
        
        return snapshot.documents.compactMap { try? $0.data(as: MonthlyPayment.self) }
    }
    
    // MARK: - Escrita de Dados
    func atualizarPagamento(_ pagamento: MonthlyPayment, userId: String) async throws {
        try collection(userId: userId).document(pagamento.id).setData(from: pagamento, merge: true)
    }
    
    func salvarPagamento(_ pagamento: MonthlyPayment, userId: String) async throws {
        try collection(userId: userId).document(pagamento.id).setData(from: pagamento)
    }
    
    func deletarPagamento(id: String, userId: String) async throws {
        try await collection(userId: userId).document(id).delete()
    }
    
    // MARK: - NOVO: Função Offline-First (Tempo Real)
    /// Cria um túnel em tempo real com o Firestore, acionando o cache local imediatamente.
    func escutarPagamentos(userId: String, onChange: @escaping ([MonthlyPayment]) -> Void) -> ListenerRegistration {
        return collection(userId: userId).addSnapshotListener { snapshot, error in
            guard let documents = snapshot?.documents else {
                print("Erro ao ouvir pagamentos: \(error?.localizedDescription ?? "Desconhecido")")
                return
            }
            
            let pagamentos = documents.compactMap { try? $0.data(as: MonthlyPayment.self) }
            onChange(pagamentos)
        }
    }
}
