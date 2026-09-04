//
//  PaymentRepositoryProtocol.swift
//  PsicoFlow
//
//  Created by Kenay on 06/04/26.
//

import Foundation

protocol PaymentRepositoryProtocol {
    func fetchPayments(userId: String) async throws -> [MonthlyPayment]
    func fetchPayments(forPatientID patientID: String, userId: String) async throws -> [MonthlyPayment]
    func updatePayment(_ payment: MonthlyPayment, userId: String) async throws
    func savePayment(_ payment: MonthlyPayment, userId: String) async throws
    func deletePayment(id: String, userId: String) async throws
}
