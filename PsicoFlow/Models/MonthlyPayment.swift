//
//  MonthlyPayment.swift
//  PsicoApp
//
//  Created by Kenay on 31/03/26.
//

import Foundation

struct MonthlyPayment: Identifiable, Codable {
    var id: String
    var psychologistID: String
    var patientID: String
    
    // Representa o mês e ano (ex: "2026/03") para facilitar filtros
    var referenceMonth: String
    
    // Data em que o pagamento foi realizado (opcional até que seja pago)
    var paymentDate: Date?
    
    var value: Double
    var paid: Bool
    
    // Propriedade para facilitar a exibição de status na UI
    var billingStatus: String {
        paid ? "Pago" : "Pendente"
    }
}
