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
    
    /// Varre os pacientes ativos e gera as faturas para o mês corrente e para o próximo mês.
    func gerarCobrancasAtuaisEFuturas() {
        let calendar = Calendar.current
        let hoje = Date()
        
        guard let proximoMes = calendar.date(byAdding: .month, value: 1, to: hoje) else { return }
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy/MM"
        
        let mesAtualStr = formatter.string(from: hoje)
        let proximoMesStr = formatter.string(from: proximoMes)
        let mesesParaProcessar = [mesAtualStr, proximoMesStr]
        
        let pacientesAtivos = patientRepository.fetchPacientes().filter { $0.status == .ativo }
        let todosPagamentos = paymentRepository.fetchPagamentos()
        
        for paciente in pacientesAtivos {
            for mesStr in mesesParaProcessar {
                let jaPossuiCobranca = todosPagamentos.contains { pagamento in
                    pagamento.pacienteID == paciente.id && pagamento.mesReferencia == mesStr
                }
                
                if !jaPossuiCobranca {
                    let novaCobranca = MonthlyPayment(
                        id: "pay_\(UUID().uuidString)",
                        psicologoID: paciente.psicologoID,
                        pacienteID: paciente.id,
                        mesReferencia: mesStr,
                        dataPagamento: nil,
                        valor: paciente.valor,
                        pago: false
                    )
                    
                    paymentRepository.salvarPagamento(novaCobranca)
                    print("💰 Mensalidade gerada para o paciente \(paciente.nome) referente a \(mesStr).")
                }
            }
        }
    }
    
    /// Remove as cobranças do mês atual e do mês seguinte caso o paciente seja desativado,
    /// preservando faturas que já tenham sido pagas.
    func removerCobrancasPendentes(para pacienteID: String) {
        let hoje = Date()
        let calendar = Calendar.current
        
        guard let proximoMes = calendar.date(byAdding: .month, value: 1, to: hoje) else { return }
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy/MM"
        
        let mesAtualStr = formatter.string(from: hoje)
        let proximoMesStr = formatter.string(from: proximoMes)
        let mesesAlvo = [mesAtualStr, proximoMesStr]
        
        let pagamentosDoPaciente = paymentRepository.fetchPagamentos(paraPacienteID: pacienteID)
        var totalDeletados = 0
        
        for pagamento in pagamentosDoPaciente {
            if mesesAlvo.contains(pagamento.mesReferencia) && !pagamento.pago {
                paymentRepository.deletarPagamento(id: pagamento.id)
                totalDeletados += 1
            }
        }
        
        if totalDeletados > 0 {
            print("🗑️ [Financeiro] \(totalDeletados) cobranças pendentes foram removidas devido à inativação do paciente.")
        }
    }
}
