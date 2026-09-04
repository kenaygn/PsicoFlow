//
//  StoreManager.swift
//  PsicoFlow
//
//  Created by Kenay on 22/07/26.
//

import Foundation
import Combine
import StoreKit

@MainActor
class StoreManager: ObservableObject {
    
    let productIDs = ["psyes_pro_mensal"]
    
    @Published var availableProducts: [Product] = []
    @Published var isPurchasing: Bool = false
    
    @Published var subscriptionExpired: Bool = false
    
    private var transactionListener: Task<Void, Error>?
    
    init() {
        transactionListener = listenForTransactions()
        Task {
            await loadProducts()
        }
    }
    
    deinit {
        transactionListener?.cancel()
    }
    
    func loadProducts() async {
        do {
            let storeProducts = try await Product.products(for: productIDs)
            self.availableProducts = storeProducts
        } catch {
            print("Error fetching products: \(error)")
        }
    }
    
    func purchase(_ product: Product) async throws -> Transaction? {
        isPurchasing = true
        defer { isPurchasing = false }
        
        let result = try await product.purchase()
        
        switch result {
        case .success(let verification):
            let transaction = try checkVerified(verification)
            await transaction.finish()
            NotificationCenter.default.post(name: NSNotification.Name("UpdateStoreKit"), object: nil)
            return transaction
            
        case .userCancelled, .pending:
            return nil
        @unknown default:
            return nil
        }
    }
    
    func syncStatusWithApple(currentUser: User?, userRepository: UserRepositoryProtocol) async {
        guard let user = currentUser else { return }
        
        var hasActiveSubscription = false
        
        for await result in Transaction.currentEntitlements {
            do {
                let transaction = try checkVerified(result)
                if transaction.productID == "psyes_pro_mensal" && transaction.revocationDate == nil {
                    hasActiveSubscription = true
                }
            } catch {
                print("Error verifying transaction: \(error)")
            }
        }
        
        var modifiedUser = user
        
        // SCENARIO A: Subscription Expired / Payment Failed / Cancelled
        if !hasActiveSubscription && user.premium {
            modifiedUser.premium = false
            try? await userRepository.updateUser(user: modifiedUser)
            
            let patientRepo = PatientFirebaseRepository()
            try? await patientRepo.blockExcessPatients(userId: user.id)
            
            await MainActor.run {
                self.subscriptionExpired = true
            }
            print("Subscription expired. Firebase updated to Free.")
        }
        // SCENARIO B: Subscription auto-renewed externally (or subscribed on another device)
        else if hasActiveSubscription && !user.premium {
            modifiedUser.premium = true
            try? await userRepository.updateUser(user: modifiedUser)
            
            let patientRepo = PatientFirebaseRepository()
            try? await patientRepo.unblockPatients(userId: user.id)
            
            print("Subscription renewed/detected. Firebase updated to Premium.")
        }
    }
    
    private func checkVerified<T>(_ result: VerificationResult<T>) throws -> T {
        switch result {
        case .unverified:
            throw StoreError.failedVerification
        case .verified(let safe):
            return safe
        }
    }
    
    private func listenForTransactions() -> Task<Void, Error> {
        return Task {
            for await result in Transaction.updates {
                do {
                    let transaction = try self.checkVerified(result)
                    await transaction.finish()
                    
                    NotificationCenter.default.post(name: NSNotification.Name("UpdateStoreKit"), object: nil)
                    
                } catch {
                    print("Unverified transaction: \(error)")
                }
            }
        }
    }
}

enum StoreError: Error {
    case failedVerification
}
