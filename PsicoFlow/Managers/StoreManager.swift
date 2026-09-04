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
    
    // O ID exato que você configurou no arquivo .storekit
    let productIDs = ["psyes_pro_mensal"]
    
    @Published var produtosDisponiveis: [Product] = []
    @Published var estaComprando: Bool = false
    
    @Published var assinaturaExpirou: Bool = false
    
    // Uma "tarefa" que fica escutando se a compra foi aprovada pela Apple
    private var transactionListener: Task<Void, Error>?
    
    init() {
        transactionListener = escutarTransacoes()
        Task {
            await carregarProdutos()
        }
    }
    
    deinit {
        transactionListener?.cancel()
    }
    
    // Busca as informações do plano direto da Apple
    func carregarProdutos() async {
        do {
            let storeProducts = try await Product.products(for: productIDs)
            self.produtosDisponiveis = storeProducts
        } catch {
            print("Erro ao buscar produtos: \(error)")
        }
    }
    
    // Aciona o modal de pagamento do iOS
    func comprar(_ product: Product) async throws -> Transaction? {
        estaComprando = true
        defer { estaComprando = false }
        
        let result = try await product.purchase()
        
        switch result {
        case .success(let verification):
            let transaction = try checkVerified(verification)
            await transaction.finish()
            NotificationCenter.default.post(name: NSNotification.Name("AtualizarStoreKit"), object: nil)
            return transaction
            
        case .userCancelled, .pending:
            return nil
        @unknown default:
            return nil
        }
    }
    
    func sincronizarStatusComApple(usuarioAtual: User?, userRepository: UserRepositoryProtocol) async {
        guard let usuario = usuarioAtual else { return }
        
        var possuiAssinaturaAtiva = false
        
        // Itera sobre as assinaturas ativas na Apple NESTE momento
        for await result in Transaction.currentEntitlements {
            do {
                let transaction = try checkVerified(result)
                // Se achou o plano e ele não foi revogado
                if transaction.productID == "psyes_pro_mensal" && transaction.revocationDate == nil {
                    possuiAssinaturaAtiva = true
                }
            } catch {
                print("Erro ao verificar transação: \(error)")
            }
        }
        
        var usuarioModificado = usuario
        
        // CENÁRIO A: Assinatura Expirou / Falhou o Pagamento / Cancelou
        if !possuiAssinaturaAtiva && usuario.premium {
            usuarioModificado.premium = false
            try? await userRepository.updateUser(user: usuarioModificado)
            
            let patientRepo = PatientFirebaseRepository()
            try? await patientRepo.blockExcessPatients(userId: usuario.id)
            
            await MainActor.run {
                self.assinaturaExpirou = true
            }
            print("Assinatura expirada. Firebase atualizado para Free.")
        }
        // CENÁRIO B: Assinatura renovou automaticamente por fora (ou assinou em outro aparelho)
        else if possuiAssinaturaAtiva && !usuario.premium {
            usuarioModificado.premium = true
            try? await userRepository.updateUser(user: usuarioModificado)
            
            let patientRepo = PatientFirebaseRepository()
            try? await patientRepo.unblockPatients(userId: usuario.id)
            
            print("Assinatura renovada/detectada. Firebase atualizado para Premium.")
        }
    }
    
    // Verifica se a transação é verdadeira
    private func checkVerified<T>(_ result: VerificationResult<T>) throws -> T {
        switch result {
        case .unverified:
            throw StoreError.failedVerification
        case .verified(let safe):
            return safe
        }
    }
    
    // Escuta compras feitas por fora
    private func escutarTransacoes() -> Task<Void, Error> {
        return Task {
            for await result in Transaction.updates {
                do {
                    let transaction = try self.checkVerified(result)
                    await transaction.finish()
                    
                    // Dispara o aviso global com segurança na Main Thread
                    NotificationCenter.default.post(name: NSNotification.Name("AtualizarStoreKit"), object: nil)
                    
                } catch {
                    print("Transação não verificada: \(error)")
                }
            }
        }
    }
}

enum StoreError: Error {
    case failedVerification
}
