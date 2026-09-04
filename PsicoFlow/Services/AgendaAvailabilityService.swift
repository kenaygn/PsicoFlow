//
//  AgendaAvailabilityService.swift
//  PsicoFlow
//
//  Created by Kenay on 25/05/26.
//

import Foundation

class AgendaAvailabilityService {
    
    private let fixedSessionRepository: FixedSessionRepositoryProtocol
    private let sessionRepository: SessionRepositoryProtocol
    
    init(
        fixedSessionRepository: FixedSessionRepositoryProtocol,
        sessionRepository: SessionRepositoryProtocol
    ) {
        self.fixedSessionRepository = fixedSessionRepository
        self.sessionRepository = sessionRepository
    }
    
    var allTimeSlots: [String] {
        let startHour = AuthManager.shared.usuarioAtual?.workdayStart ?? "07:00"
        let endHour = AuthManager.shared.usuarioAtual?.workdayEnd ?? "22:00"
        
        if let startInt = Int(startHour.prefix(2)),
           let endInt = Int(endHour.prefix(2)),
           startInt <= endInt {
            return (startInt...endInt).map { String(format: "%02d:00", $0) }
        } else {
            return (7...22).map { String(format: "%02d:00", $0) }
        }
    }
    
    func freeSlotsForContract(weekday: Int, ignoringContractID: String? = nil, userId: String) async throws -> [String] {
        let contractsFromDB = try await fixedSessionRepository.fetchFixedSessions(userId: userId)
        let rulesOnSameDay = contractsFromDB.filter { $0.weekday == weekday && $0.id != ignoringContractID }
        let occupied = rulesOnSameDay.map { $0.startTime }
        return allTimeSlots.filter { !occupied.contains($0) }
    }
    
    func freeSlotsForSingleSession(date: Date, ignoringSessionID: String? = nil, derivedFromContractID: String? = nil, userId: String) async throws -> [String] {
        let sessionsFromDB = try await sessionRepository.fetchSessions(userId: userId)
        let sessionsOnDay = sessionsFromDB.filter {
            Calendar.current.isDate($0.sessionDate, inSameDayAs: date) &&
            $0.status != .cancelled &&
            $0.id != ignoringSessionID
        }
        let occupied = sessionsOnDay.map { $0.startTime }
        return allTimeSlots.filter { !occupied.contains($0) }
    }
}
