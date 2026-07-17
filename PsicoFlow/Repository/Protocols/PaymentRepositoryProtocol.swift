//
//  PaymentRepositoryProtocol.swift
//  PsicoFlow
//
//  Created by Kenay on 06/04/26.
//

import Foundation

protocol PaymentRepositoryProtocol {
    func fetchPagamentos(userId: String) async throws -> [MonthlyPayment]
    func fetchPagamentos(paraPacienteID pacienteID: String, userId: String) async throws -> [MonthlyPayment]
    func atualizarPagamento(_ pagamento: MonthlyPayment, userId: String) async throws
    func salvarPagamento(_ pagamento: MonthlyPayment, userId: String) async throws
    func deletarPagamento(id: String, userId: String) async throws
}
