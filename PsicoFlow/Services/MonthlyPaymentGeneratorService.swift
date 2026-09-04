//
//  MonthlyPaymentGeneratorService.swift
//  PsicoFlow
//

import Foundation

/// Service responsible for ensuring automatic generation and maintenance of monthly charges.
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
    
    func generateCurrentAndFutureCharges(userId: String) async throws {
        let calendar = Calendar.current
        let today = Date()
        
        guard let nextMonth = calendar.date(byAdding: .month, value: 1, to: today) else { return }
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy/MM"
        
        let currentMonthStr = formatter.string(from: today)
        let nextMonthStr = formatter.string(from: nextMonth)
        let monthsToProcess = [currentMonthStr, nextMonthStr]
        
        let patientsFromDB = try await patientRepository.fetchPatients(userId: userId)
        let activePatients = patientsFromDB.filter { $0.status == .active }
        let allPayments = try await paymentRepository.fetchPayments(userId: userId)
        
        for patient in activePatients {
            for monthStr in monthsToProcess {
                let alreadyHasCharge = allPayments.contains { payment in
                    payment.patientID == patient.id && payment.referenceMonth == monthStr
                }
                
                if !alreadyHasCharge {
                    let newCharge = MonthlyPayment(
                        id: "pay_\(UUID().uuidString)",
                        psychologistID: userId,
                        patientID: patient.id,
                        referenceMonth: monthStr,
                        paymentDate: nil,
                        value: patient.value,
                        paid: false
                    )
                    
                    try await paymentRepository.savePayment(newCharge, userId: userId)
                    print("Monthly charge generated for patient \(patient.name) referring to \(monthStr).")
                }
            }
        }
    }
    
    func removePendingCharges(for patientID: String, userId: String) async throws {
        let today = Date()
        let calendar = Calendar.current
        
        guard let nextMonth = calendar.date(byAdding: .month, value: 1, to: today) else { return }
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy/MM"
        
        let currentMonthStr = formatter.string(from: today)
        let nextMonthStr = formatter.string(from: nextMonth)
        let targetMonths = [currentMonthStr, nextMonthStr]
        
        let patientPayments = try await paymentRepository.fetchPayments(forPatientID: patientID, userId: userId)
        var totalDeleted = 0
        
        for payment in patientPayments {
            if targetMonths.contains(payment.referenceMonth) && !payment.paid {
                try await paymentRepository.deletePayment(id: payment.id, userId: userId)
                totalDeleted += 1
            }
        }
        
        if totalDeleted > 0 {
            print("[Finance] \(totalDeleted) pending charges were removed due to patient deactivation.")
        }
    }
    
    func updatePendingPaymentsValue(patientID: String, newValue: Double, userId: String) async throws {
        let payments = try await paymentRepository.fetchPayments(forPatientID: patientID, userId: userId)
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy/MM"
        let currentMonthStr = formatter.string(from: Date())
        
        for var payment in payments {
            
            let isCurrentOrFutureMonth = payment.referenceMonth >= currentMonthStr
            
            if isCurrentOrFutureMonth && !payment.paid {
                
                payment.value = newValue
                
                try await paymentRepository.updatePayment(payment, userId: userId)
            }
        }
    }
}
