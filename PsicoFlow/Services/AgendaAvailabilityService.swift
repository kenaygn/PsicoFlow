//
//  AgendaAvailabilityService.swift
//  PsicoFlow
//
//  Created by Kenay on 25/05/26.
//

import Foundation

/// Serviço responsável por calcular a disponibilidade de horários na agenda do psicólogo,
/// evitando conflitos entre sessões avulsas e contratos recorrentes.
class AgendaAvailabilityService {
    
    private let fixedSessionRepository: FixedSessionRepositoryProtocol
    private let sessionRepository: SessionRepositoryProtocol
    
    // Matriz de horários do expediente mantida de forma estática por enquanto
    let todosHorarios: [String] = [
        "07:00", "08:00", "09:00", "10:00", "11:00", "12:00",
        "13:00", "14:00", "15:00", "16:00", "17:00", "18:00", "19:00", "20:00", "21:00", "22:00"
    ]
    
    init(
        fixedSessionRepository: FixedSessionRepositoryProtocol,
        sessionRepository: SessionRepositoryProtocol
    ) {
        self.fixedSessionRepository = fixedSessionRepository
        self.sessionRepository = sessionRepository
    }
    
    /// Calcula os horários livres para criar ou editar um Contrato Fixo.
    /// - Parameters:
    ///   - diaDaSemana: O dia alvo (1 = Domingo, 2 = Segunda...)
    ///   - ignorandoContratoID: Opcional. O ID do contrato atual em caso de edição, para que ele não bloqueie a si mesmo.
    ///   - userId: O ID do psicólogo logado.
    func horariosLivresParaContrato(diaDaSemana: Int, ignorandoContratoID: String? = nil, userId: String) async throws -> [String] {
        // Busca assíncrona dos contratos no Firebase
        let contratosDoBanco = try await fixedSessionRepository.fetchSessoesFixas(userId: userId)
        
        let regrasNoMesmoDia = contratosDoBanco.filter {
            $0.diaDaSemana == diaDaSemana && $0.id != ignorandoContratoID
        }
        
        let ocupados = regrasNoMesmoDia.map { $0.horaInicio }
        return todosHorarios.filter { !ocupados.contains($0) }
    }
    
    /// Calcula os horários livres para criar ou editar uma Sessão Avulsa para uma data específica.
    /// - Parameters:
    ///   - data: A data exata desejada.
    ///   - ignorandoSessaoID: Opcional. O ID da sessão atual em caso de edição.
    ///   - derivadaDeContratoID: Opcional. Se a sessão nasceu de um contrato, passa o ID do contrato para ele não bloquear a si mesmo.
    ///   - userId: O ID do psicólogo logado.
    func horariosLivresParaSessaoAvulsa(data: Date, ignorandoSessaoID: String? = nil, derivadaDeContratoID: String? = nil, userId: String) async throws -> [String] {
        let weekdayDaData = Calendar.current.component(.weekday, from: data)
        
        // Buscas assíncronas no Firebase
        let contratosDoBanco = try await fixedSessionRepository.fetchSessoesFixas(userId: userId)
        let sessoesDoBanco = try await sessionRepository.fetchSessoes(userId: userId)
        
        // Regras fixas que caem neste dia
        let regrasFixas = contratosDoBanco.filter {
            $0.diaDaSemana == weekdayDaData && $0.id != derivadaDeContratoID
        }
        
        // Outras sessões avulsas marcadas para este mesmo dia exato
        let outrasAvulsas = sessoesDoBanco.filter {
            Calendar.current.isDate($0.dataDaSessão, inSameDayAs: data) &&
            $0.status != .cancelada &&
            $0.id != ignorandoSessaoID
        }
        
        let ocupadosFixas = regrasFixas.map { $0.horaInicio }
        let ocupadosAvulsas = outrasAvulsas.map { $0.horaInicio }
        let todosOcupados = ocupadosFixas + ocupadosAvulsas
        
        return todosHorarios.filter { !todosOcupados.contains($0) }
    }
}
