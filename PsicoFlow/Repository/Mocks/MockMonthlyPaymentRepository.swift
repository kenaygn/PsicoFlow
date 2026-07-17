//
//  MockMonthlyPaymentRepository.swift
//  PsicoFlow
//
//  Created by Kenay on 06/04/26.
//

import Foundation

//class MockPaymentRepository: PaymentRepositoryProtocol {
//    func fetchPagamentos() -> [MonthlyPayment] {
//        return MockData.pagamentosExemplo
//    }
//    
//    // Filtra os pagamentos só do paciente aberto
//    func fetchPagamentos(paraPacienteID pacienteID: String) -> [MonthlyPayment] {
//        return MockData.pagamentosExemplo.filter { $0.pacienteID == pacienteID }
//    }
//    
//    // Salva a alteração (Pago/Pendente) no banco de dados
//    func atualizarPagamento(_ pagamento: MonthlyPayment) {
//        if let index = MockData.pagamentosExemplo.firstIndex(where: { $0.id == pagamento.id }) {
//            MockData.pagamentosExemplo[index] = pagamento
//        }
//    }
//    
//    func salvarPagamento(_ pagamento: MonthlyPayment) {
//            MockData.pagamentosExemplo.append(pagamento)
//        }
//    
//    func deletarPagamento(id: String) {
//            MockData.pagamentosExemplo.removeAll(where: { $0.id == id })
//        }
//}
