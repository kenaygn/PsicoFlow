//
//  FinanceAnalyzerService.swift
//  PsicoFlow
//
//  Created by Kenay on 09/05/26.
//


import Foundation

///Analisa o histórico de pagamentos para identificar atrasos e métricas.
class FinanceAnalyzerService {
    
    /// Retorna a data (mês/ano) da primeira pendência financeira encontrada em meses anteriores ao atual.
    func identificarPrimeiroMesComAtraso(nos pagamentos: [MonthlyPayment]) -> Date? {
        let calendar = Calendar.current
        let agora = Date()
        
        // Filtra apenas pagamentos não quitados
        let pendentes = pagamentos.filter { !$0.pago }
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy/MM"
        
        // Converte as strings "yyyy/MM" em Dates reais para comparação
        let datasPendentes = pendentes.compactMap { p -> Date? in
            return formatter.date(from: p.mesReferencia)
        }
        
        // Filtra apenas datas que são estritamente anteriores ao mês atual
        let atrasosReais = datasPendentes.filter { dataPendente in
            guard let inicioDoMesAtual = calendar.date(from: calendar.dateComponents([.year, .month], from: agora)) else { return false }
            return dataPendente < inicioDoMesAtual
        }
        
        // Retorna a mais antiga (a primeira que ele esqueceu de pagar)
        return atrasosReais.sorted().first
    }
}
