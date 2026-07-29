//
//  SystemUpdateManager.swift
//  PsicoFlow
//
//  Created by Kenay on 25/05/26.
//

import Foundation

/// Classe Singleton responsável por rodar rotinas de manutenção e atualizações automáticas
/// sempre que o aplicativo é trazido para o primeiro plano (Foreground).
class SystemUpdateManager {
    
    static let shared = SystemUpdateManager()
    
    private let faturamentoService: MonthlyPaymentGeneratorService
    private let generatorService: SessionGeneratorService
    
    private init() {
        let patientRepo = PatientFirebaseRepository()
        let paymentRepo = PaymentFirebaseRepository()
        let fixedSessionRepo = FixedSessionFirebaseRepository()
        let sessionRepo = SessionFirebaseRepository()
        
        self.faturamentoService = MonthlyPaymentGeneratorService(
            patientRepository: patientRepo,
            paymentRepository: paymentRepo
        )
        
        self.generatorService = SessionGeneratorService(
            patientRepository: patientRepo,
            fixedSessionRepository: fixedSessionRepo,
            sessionRepository: sessionRepo
        )
    }
    
    func runStartupChecks(userId: String) {
        guard !userId.isEmpty else { return }
        
        print("[System Manager] A executar verificações de sistema...")
        
        Task {
            do {
                try await faturamentoService.gerarCobrancasAtuaisEFuturas(userId: userId)
                try await generatorService.projetarSessoesFuturas(userId: userId)
                
                print("[System Manager] Verificações concluídas.")
            } catch {
                print("[System Manager] Erro durante as verificações: \(error.localizedDescription)")
            }
        }
    }
}
