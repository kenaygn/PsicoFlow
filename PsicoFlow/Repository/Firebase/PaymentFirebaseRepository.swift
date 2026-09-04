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
    
    func fetchPayments(userId: String) async throws -> [MonthlyPayment] {
        let snapshot = try await collection(userId: userId).getDocuments()
        return snapshot.documents.compactMap { try? $0.data(as: MonthlyPayment.self) }
    }
    
    func fetchPayments(forPatientID patientID: String, userId: String) async throws -> [MonthlyPayment] {
        let snapshot = try await collection(userId: userId)
            .whereField("patientID", isEqualTo: patientID)
            .getDocuments()
        
        return snapshot.documents.compactMap { try? $0.data(as: MonthlyPayment.self) }
    }
    
    func updatePayment(_ payment: MonthlyPayment, userId: String) async throws {
        try collection(userId: userId).document(payment.id).setData(from: payment, merge: true)
    }
    
    func savePayment(_ payment: MonthlyPayment, userId: String) async throws {
        try collection(userId: userId).document(payment.id).setData(from: payment)
    }
    
    func deletePayment(id: String, userId: String) async throws {
        try await collection(userId: userId).document(id).delete()
    }
    
    /// Real-time tunnel with Firestore, triggering the local cache immediately.
    func listenToPayments(userId: String, onChange: @escaping ([MonthlyPayment]) -> Void) -> ListenerRegistration {
        return collection(userId: userId).addSnapshotListener { snapshot, error in
            guard let documents = snapshot?.documents else {
                print("Error listening to payments: \(error?.localizedDescription ?? "Unknown")")
                return
            }
            
            let payments = documents.compactMap { try? $0.data(as: MonthlyPayment.self) }
            onChange(payments)
        }
    }
}
