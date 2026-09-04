//
//  FinanceAnalyzerService.swift
//  PsicoFlow
//
//  Created by Kenay on 09/05/26.
//

import Foundation

/// Analyzes payment history to identify overdue charges and metrics.
class FinanceAnalyzerService {
    
    func identifyFirstOverdueMonth(in payments: [MonthlyPayment]) -> Date? {
        let calendar = Calendar.current
        let now = Date()
        
        let pending = payments.filter { !$0.paid }
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy/MM"
        
        let pendingDates = pending.compactMap { p -> Date? in
            return formatter.date(from: p.referenceMonth)
        }
        
        let actualOverdues = pendingDates.filter { pendingDate in
            guard let startOfCurrentMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: now)) else { return false }
            return pendingDate < startOfCurrentMonth
        }
        
        return actualOverdues.sorted().first
    }
}
