//
//  SessionGeneratorService.swift
//  PsicoFlow
//
//  Created by Kenay on 13/04/26.
//

import Foundation

class SessionGeneratorService {
    
    private let patientRepository: PatientRepositoryProtocol
    private let fixedSessionRepository: FixedSessionRepositoryProtocol
    private let sessionRepository: SessionRepositoryProtocol
    
    init(
        patientRepository: PatientRepositoryProtocol,
        fixedSessionRepository: FixedSessionRepositoryProtocol,
        sessionRepository: SessionRepositoryProtocol
    ) {
        self.patientRepository = patientRepository
        self.fixedSessionRepository = fixedSessionRepository
        self.sessionRepository = sessionRepository
    }
    
    func projectFutureSessions(userId: String) async throws {
        let today = Calendar.current.startOfDay(for: Date())
        let endDate = lastDayOfNextMonth()
        
        let fixedRules = try await fixedSessionRepository.fetchFixedSessions(userId: userId)
        let allPatients = try await patientRepository.fetchPatients(userId: userId)
        
        let activePatientIDs = allPatients.filter { $0.status == .active }.map { $0.id }
        
        var existingSessions = try await sessionRepository.fetchSessions(userId: userId)
        

        var totalRemoved = 0
        
        for session in existingSessions {
            if session.sessionDate >= today && session.fixedSessionID != nil {
                if !activePatientIDs.contains(session.patientID) {
                    try await sessionRepository.deleteSession(id: session.id, userId: userId)
                    totalRemoved += 1
                }
            }
        }
        
        if totalRemoved > 0 {
            print("[Session Generator] \(totalRemoved) future sessions removed from inactive patients.")
            existingSessions = try await sessionRepository.fetchSessions(userId: userId)
        }
        
        var totalGenerated = 0
        
        for rule in fixedRules {
            if activePatientIDs.contains(rule.patientID) {
                
                let projectedSessions = generateSessions(for: rule, endDate: endDate)
                
                for newSession in projectedSessions {
                    let alreadyExists = existingSessions.contains {
                        $0.fixedSessionID == rule.id &&
                        Calendar.current.isDate($0.sessionDate, inSameDayAs: newSession.sessionDate)
                    }
                    
                    if !alreadyExists {
                        try await sessionRepository.saveSession(newSession, userId: userId)
                        totalGenerated += 1
                    }
                }
            }
        }
        
        if totalGenerated > 0 {
            print("[Session Generator] \(totalGenerated) new recurring sessions added to the schedule.")
        }
    }
    
    func generateSessions(for rule: FixedSession, startDate: Date = Date(), endDate: Date) -> [Session] {
        let calendar = Calendar.current
        var generatedSessions: [Session] = []
        
        var currentDate = startDate
        
        while currentDate <= endDate {
            let currentWeekday = calendar.component(.weekday, from: currentDate)
            
            if currentWeekday == rule.weekday {
                
                let newSession = Session(
                    id: UUID().uuidString,
                    psychologistID: rule.psychologistID,
                    patientID: rule.patientID,
                    fixedSessionID: rule.id,
                    sessionDate: currentDate,
                    status: .scheduled,
                    modality: rule.modality,
                    startTime: rule.startTime
                )
                
                generatedSessions.append(newSession)
            }
            
            guard let nextDay = calendar.date(byAdding: .day, value: 1, to: currentDate) else { break }
            currentDate = nextDay
        }
        
        return generatedSessions
    }
    
    func lastDayOfNextMonth(from date: Date = Date()) -> Date {
        let calendar = Calendar.current
        guard let nextMonth = calendar.date(byAdding: .month, value: 1, to: date),
              let startOfNextMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: nextMonth)),
              let endOfNextMonth = calendar.date(byAdding: DateComponents(month: 1, day: -1), to: startOfNextMonth) else {
            return Date()
        }
        return endOfNextMonth
    }
}
