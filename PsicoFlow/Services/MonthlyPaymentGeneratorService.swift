//
//  MonthlyPaymentGeneratorService.swift
//  PsicoFlow
//
//  Created by Kenay on 25/05/26.
//

import Foundation

/// Serviço responsável por garantir a geração automática de mensalidades.
/// Gera a cobrança do mês atual e já adianta a cobrança do mês seguinte,
/// garantindo previsibilidade imediata no fluxo de caixa do psicólogo.
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
    
    /// Varre os pacientes ativos e gera as faturas para o mês corrente e para o próximo mês
    /// caso elas ainda não existam. O método é seguro e não cria duplicatas.
    func gerarCobrancasAtuaisEFuturas() {
        let calendar = Calendar.current
        let hoje = Date()
        
        // Calcula a data exata do mês que vem
        guard let proximoMes = calendar.date(byAdding: .month, value: 1, to: hoje) else { return }
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy/MM"
        
        let mesAtualStr = formatter.string(from: hoje)
        let proximoMesStr = formatter.string(from: proximoMes)
        
        // Array com os dois meses que queremos garantir que existam
        let mesesParaProcessar = [mesAtualStr, proximoMesStr]
        
        // 1. Busca todos os pacientes ativos
        let pacientesAtivos = patientRepository.fetchPacientes().filter { $0.status == .ativo }
        
        // 2. Busca o histórico de pagamentos uma única vez para otimizar a memória
        let todosPagamentos = paymentRepository.fetchPagamentos()
        
        // 3. Processa paciente por paciente
        for paciente in pacientesAtivos {
            
            // 4. Verifica os dois meses-alvo (Atual e Próximo)
            for mesStr in mesesParaProcessar {
                
                // Verifica se JÁ EXISTE uma fatura para este paciente neste mês específico
                let jaPossuiCobranca = todosPagamentos.contains { pagamento in
                    pagamento.pacienteID == paciente.id && pagamento.mesReferencia == mesStr
                }
                
                // Se não tem cobrança, o sistema gera automaticamente
                if !jaPossuiCobranca {
                    let novaCobranca = MonthlyPayment(
                        id: "pay_\(UUID().uuidString)",
                        psicologoID: paciente.psicologoID,
                        pacienteID: paciente.id,
                        mesReferencia: mesStr,
                        dataPagamento: nil,
                        valor: paciente.valor, // O valor fixo combinado da mensalidade do paciente
                        pago: false
                    )
                    
                    paymentRepository.salvarPagamento(novaCobranca)
                    print("💰 Mensalidade gerada para o paciente \(paciente.nome) referente a \(mesStr).")
                }
            }
        }
    }
}
