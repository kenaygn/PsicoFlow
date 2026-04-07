//
//  MonthlyPayment.swift
//  PsicoApp
//
//  Created by Kenay on 31/03/26.
//

import Foundation

struct MonthlyPayment: Identifiable, Codable {
    var id: String
    var psicologoID: String
    var pacienteID: String
    
    // Representa o mês e ano (ex: "2026/03") para facilitar filtros
    var mesReferencia: String
    
    // Data em que o pagamento foi realizado (opcional até que seja pago)
    var dataPagamento: Date?
    
    var valor: Double
    var pago: Bool
    
    // Propriedade para facilitar a exibição de status na UI
    var statusCobranca: String {
        pago ? "Pago" : "Pendente"
    }
}
