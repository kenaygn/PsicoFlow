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
    
    /// gera para o mês corrente e para o próximo mês.
    func gerarCobrancasAtuaisEFuturas(userId: String) async throws {
        let calendar = Calendar.current
        let hoje = Date()
        
        guard let proximoMes = calendar.date(byAdding: .month, value: 1, to: hoje) else { return }
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy/MM"
        
        let mesAtualStr = formatter.string(from: hoje)
        let proximoMesStr = formatter.string(from: proximoMes)
        let mesesParaProcessar = [mesAtualStr, proximoMesStr]
        
        let pacientesDoBanco = try await patientRepository.fetchPacientes(userId: userId)
        let pacientesAtivos = pacientesDoBanco.filter { $0.status == .active }
        let todosPagamentos = try await paymentRepository.fetchPagamentos(userId: userId)
        
        for paciente in pacientesAtivos {
            for mesStr in mesesParaProcessar {
                let jaPossuiCobranca = todosPagamentos.contains { pagamento in
                    pagamento.patientID == paciente.id && pagamento.referenceMonth == mesStr
                }
                
                if !jaPossuiCobranca {
                    let novaCobranca = MonthlyPayment(
                        id: "pay_\(UUID().uuidString)",
                        psychologistID: userId, // Utiliza o ID seguro fornecido por parâmetro
                        patientID: paciente.id,
                        referenceMonth: mesStr,
                        paymentDate: nil,
                        value: paciente.value,
                        paid: false
                    )
                    
                    try await paymentRepository.salvarPagamento(novaCobranca, userId: userId)
                    print("Mensalidade gerada para o paciente \(paciente.name) referente a \(mesStr).")
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
        
        let pagamentosDoPaciente = try await paymentRepository.fetchPagamentos(paraPacienteID: pacienteID, userId: userId)
        var totalDeletados = 0
        
        for pagamento in pagamentosDoPaciente {
            if mesesAlvo.contains(pagamento.referenceMonth) && !pagamento.paid {
                try await paymentRepository.deletarPagamento(id: pagamento.id, userId: userId)
                totalDeletados += 1
            }
        }
        
        if totalDeletados > 0 {
            print("[Financeiro] \(totalDeletados) cobranças pendentes foram removidas devido à inativação do paciente.")
        }
    }
    
    /// Atualiza o valor de todas as cobranças do mês atual e dos meses futuros que ainda não foram pagas.
    func atualizarValorPagamentosPendentes(pacienteID: String, novoValor: Double, userId: String) async throws {
        let pagamentos = try await paymentRepository.fetchPagamentos(paraPacienteID: pacienteID, userId: userId)
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy/MM"
        let mesAtualStr = formatter.string(from: Date())
        
        for var pagamento in pagamentos {

            let isMesAtualOuFuturo = pagamento.referenceMonth >= mesAtualStr
            
            if isMesAtualOuFuturo && !pagamento.paid {
                
                pagamento.value = novoValor
                
                try await paymentRepository.atualizarPagamento(pagamento, userId: userId)
            }
        }
    }
}
