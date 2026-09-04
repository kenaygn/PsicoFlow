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
    
    var todosHorarios: [String] {
        let horaInicio = AuthManager.shared.usuarioAtual?.workdayStart ?? "07:00"
        let horaFim = AuthManager.shared.usuarioAtual?.workdayEnd ?? "22:00"
        
        if let inicioInt = Int(horaInicio.prefix(2)),
           let fimInt = Int(horaFim.prefix(2)),
           inicioInt <= fimInt {
            return (inicioInt...fimInt).map { String(format: "%02d:00", $0) }
        } else {
            return (7...22).map { String(format: "%02d:00", $0) }
        }
    }
    
    func horariosLivresParaContrato(diaDaSemana: Int, ignorandoContratoID: String? = nil, userId: String) async throws -> [String] {
        let contratosDoBanco = try await fixedSessionRepository.fetchSessoesFixas(userId: userId)
        let regrasNoMesmoDia = contratosDoBanco.filter { $0.weekday == diaDaSemana && $0.id != ignorandoContratoID }
        let ocupados = regrasNoMesmoDia.map { $0.startTime }
        return todosHorarios.filter { !ocupados.contains($0) }
    }
    
    func horariosLivresParaSessaoAvulsa(data: Date, ignorandoSessaoID: String? = nil, derivadaDeContratoID: String? = nil, userId: String) async throws -> [String] {
        let sessoesDoBanco = try await sessionRepository.fetchSessoes(userId: userId)
        let sessoesDoDia = sessoesDoBanco.filter {
            Calendar.current.isDate($0.sessionDate, inSameDayAs: data) &&
            $0.status != .cancelled &&
            $0.id != ignorandoSessaoID
        }
        let ocupados = sessoesDoDia.map { $0.startTime }
        return todosHorarios.filter { !ocupados.contains($0) }
    }
}
