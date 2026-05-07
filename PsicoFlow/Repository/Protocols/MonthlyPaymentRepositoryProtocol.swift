//
//  MonthlyPaymentRepositoryProtocol.swift
//  PsicoFlow
//
//  Created by Kenay on 06/04/26.
//

import Foundation

protocol PaymentRepositoryProtocol {
    func fetchPagamentos() -> [MonthlyPayment]
    func fetchPagamentos(paraPacienteID pacienteID: String) -> [MonthlyPayment]
    func atualizarPagamento(_ pagamento: MonthlyPayment)
}
