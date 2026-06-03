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
        let patientRepo = MockPatientRepository()
        let paymentRepo = MockPaymentRepository()
        let fixedSessionRepo = MockFixedSessionRepository()
        let sessionRepo = MockSessionRepository()
        
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
    
    func runStartupChecks() {
        print("🔄 [System Manager] A executar verificações de sistema...")
        
        faturamentoService.gerarCobrancasAtuaisEFuturas()
        generatorService.projetarSessoesFuturas()
        
        print("✅ [System Manager] Verificações concluídas.")
    }
}
