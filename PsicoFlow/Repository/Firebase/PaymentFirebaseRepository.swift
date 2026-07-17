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
    
    func atualizarPagamento(_ pagamento: MonthlyPayment, userId: String) async throws {
        try collection(userId: userId).document(pagamento.id).setData(from: pagamento, merge: true)
    }
    
    func salvarPagamento(_ pagamento: MonthlyPayment, userId: String) async throws {
        try collection(userId: userId).document(pagamento.id).setData(from: pagamento)
    }
    
    func deletarPagamento(id: String, userId: String) async throws {
        try await collection(userId: userId).document(id).delete()
    }
}
