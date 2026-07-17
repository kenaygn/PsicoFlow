//
//  MonthlyPaymentGeneratorService.swift
//  PsicoFlow
//
//  Created by Kenay on 25/05/26.
//

import Foundation

/// Serviço responsável por garantir a geração e manutenção automática de mensalidades.
class MonthlyPaymentGeneratorService {
    
    private let patientRepository: PatientRepositoryProtocol
    private let paymentRepository: PaymentRepositoryProtocol
    
    init(
        patientRepository: PatientRepositoryProtocol,
        paymentRepository: PaymentRepositoryProtocol
    ) {
        self.patientRepository = patientRepository
        self.paymentRepository = paymentRepository
    }
    
    
    // MARK: - TODO: MIGRAÇÃO PARA BACKEND (FIREBASE CLOUD FUNCTIONS)
    // TODO: [V2.0] Esta lógica é executada no "Client-Side" (depende de o app ser aberto).
    // Para garantir que faturas sejam geradas no dia 1º mesmo se o psicólogo ficar meses
    // sem abrir o app, esta função deve ser migrada para um Cron Job no Firebase (Server-Side).
    
    /// Varre os pacientes ativos e gera as faturas para o mês corrente e para o próximo mês.
    func gerarCobrancasAtuaisEFuturas(userId: String) async throws {
        let calendar = Calendar.current
        let hoje = Date()
        
        guard let proximoMes = calendar.date(byAdding: .month, value: 1, to: hoje) else { return }
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy/MM"
        
        let mesAtualStr = formatter.string(from: hoje)
        let proximoMesStr = formatter.string(from: proximoMes)
        let mesesParaProcessar = [mesAtualStr, proximoMesStr]
        
        // 1. Buscas assíncronas no Firebase usando o userId
        let pacientesDoBanco = try await patientRepository.fetchPacientes(userId: userId)
        let pacientesAtivos = pacientesDoBanco.filter { $0.status == .ativo }
        let todosPagamentos = try await paymentRepository.fetchPagamentos(userId: userId)
        
        for paciente in pacientesAtivos {
            for mesStr in mesesParaProcessar {
                let jaPossuiCobranca = todosPagamentos.contains { pagamento in
                    pagamento.pacienteID == paciente.id && pagamento.mesReferencia == mesStr
                }
                
                if !jaPossuiCobranca {
                    let novaCobranca = MonthlyPayment(
                        id: "pay_\(UUID().uuidString)",
                        psicologoID: userId, // Utiliza o ID seguro fornecido por parâmetro
                        pacienteID: paciente.id,
                        mesReferencia: mesStr,
                        dataPagamento: nil,
                        valor: paciente.valor,
                        pago: false
                    )
                    
                    // 2. Persistência assíncrona
                    try await paymentRepository.salvarPagamento(novaCobranca, userId: userId)
                    print("💰 Mensalidade gerada para o paciente \(paciente.nome) referente a \(mesStr).")
                }
            }
        }
    }
    
    /// Remove as cobranças do mês atual e do mês seguinte caso o paciente seja desativado,
    /// preservando faturas que já tenham sido pagas.
    func removerCobrancasPendentes(para pacienteID: String, userId: String) async throws {
        let hoje = Date()
        let calendar = Calendar.current
        
        guard let proximoMes = calendar.date(byAdding: .month, value: 1, to: hoje) else { return }
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy/MM"
        
        let mesAtualStr = formatter.string(from: hoje)
        let proximoMesStr = formatter.string(from: proximoMes)
        let mesesAlvo = [mesAtualStr, proximoMesStr]
        
        // 3. Busca assíncrona focada no paciente
        let pagamentosDoPaciente = try await paymentRepository.fetchPagamentos(paraPacienteID: pacienteID, userId: userId)
        var totalDeletados = 0
        
        for pagamento in pagamentosDoPaciente {
            if mesesAlvo.contains(pagamento.mesReferencia) && !pagamento.pago {
                // 4. Deleção assíncrona
                try await paymentRepository.deletarPagamento(id: pagamento.id, userId: userId)
                totalDeletados += 1
            }
        }
        
        if totalDeletados > 0 {
            print("🗑️ [Financeiro] \(totalDeletados) cobranças pendentes foram removidas devido à inativação do paciente.")
        }
    }
}
