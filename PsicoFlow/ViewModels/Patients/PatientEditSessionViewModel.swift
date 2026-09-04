//
//  PatientEditSessionViewModel.swift
//  PsicoFlow
//
//  Created by Kenay on 05/05/26.
//

import Foundation
import Combine

/// Enum que encapsula os tipos de sessão editáveis, garantindo tipagem forte
/// e conformidade com `Identifiable` para uso seguro em Views do SwiftUI.
enum EditSessionItem: Identifiable {
    case fixa(FixedSession)
    case avulsa(Session)
    
    var id: String {
        switch self {
        case .fixa(let f): return "fixa_\(f.id)"
        case .avulsa(let a): return "avulsa_\(a.id)"
        }
    }
}

/// ViewModel responsável pela lógica de negócio e validação na edição de agendamentos.
/// Gerencia a resolução de conflitos de horários em tempo real, distinguindo regras
/// para contratos recorrentes (fixas) e eventos pontuais (avulsas).
class PatientEditSessionViewModel: ObservableObject {
    
    // MARK: - Properties
    
    let itemToEdit: EditSessionItem
    let nomePaciente: String
    
    @Published var selectedModalidade: Modality
    @Published var selectedTime: String
    @Published var selectedWeekday: Int = 1
    @Published var selectedDate: Date = Date()
    @Published var horariosLivres: [String] = []
    
    private let fixedSessionRepository: FixedSessionRepositoryProtocol
    private let sessionRepository: SessionRepositoryProtocol
    private let availabilityService: AgendaAvailabilityService
    
    init(
        item: EditSessionItem,
        nomePaciente: String,
        fixedSessionRepository: FixedSessionRepositoryProtocol = FixedSessionFirebaseRepository(),
        sessionRepository: SessionRepositoryProtocol = SessionFirebaseRepository()
    ) {
        self.itemToEdit = item
        self.nomePaciente = nomePaciente
        self.fixedSessionRepository = fixedSessionRepository
        self.sessionRepository = sessionRepository
        
        self.availabilityService = AgendaAvailabilityService(
            fixedSessionRepository: fixedSessionRepository,
            sessionRepository: sessionRepository
        )
        
        switch item {
        case .fixa(let fixa):
            self.selectedModalidade = fixa.modalidade
            self.selectedWeekday = fixa.diaDaSemana
            self.selectedTime = fixa.horaInicio
        case .avulsa(let avulsa):
            self.selectedModalidade = avulsa.modality
            self.selectedDate = avulsa.sessionDate
            self.selectedTime = avulsa.startTime
        }
    }
    
    var isFixa: Bool {
        if case .fixa = itemToEdit { return true }
        return false
    }
    
    /// Busca horários disponíveis de forma assíncrona usando o serviço de domínio.
    func carregarHorariosLivres(userId: String) {
        Task {
            do {
                switch itemToEdit {
                case .fixa(let fixaAtual):
                    self.horariosLivres = try await availabilityService.horariosLivresParaContrato(
                        diaDaSemana: selectedWeekday,
                        ignorandoContratoID: fixaAtual.id,
                        userId: userId
                    )
                case .avulsa(let avulsaAtual):
                    self.horariosLivres = try await availabilityService.horariosLivresParaSessaoAvulsa(
                        data: selectedDate,
                        ignorandoSessaoID: avulsaAtual.id,
                        derivadaDeContratoID: avulsaAtual.fixedSessionID,
                        userId: userId
                    )
                }
                atualizarSelecaoDeHorario()
            } catch {
                print("Erro ao carregar horários: \(error.localizedDescription)")
            }
        }
    }
    
    func atualizarSelecaoDeHorario() {
        if !horariosLivres.contains(selectedTime) {
            selectedTime = horariosLivres.first ?? ""
        }
    }
    
    /// Persiste as modificações no Firebase de forma assíncrona.
    func salvarEdicao(userId: String) {
        Task {
            do {
                switch itemToEdit {
                case .fixa(let fixa):
                    var atualizada = fixa
                    atualizada.modalidade = selectedModalidade
                    atualizada.diaDaSemana = selectedWeekday
                    atualizada.horaInicio = selectedTime
                    try await fixedSessionRepository.atualizarSessaoFixa(atualizada, userId: userId)
                    try await propagarAlteracoesParaSessoesFuturas(regraAtualizada: atualizada, userId: userId)
                    
                case .avulsa(let avulsa):
                    var atualizada = avulsa
                    atualizada.modality = selectedModalidade
                    atualizada.sessionDate = selectedDate
                    atualizada.startTime = selectedTime
                    if atualizada.status == .postponed { atualizada.status = .scheduled }
                    try await sessionRepository.atualizarSessao(atualizada, userId: userId)
                }
            } catch {
                print("Erro ao salvar edição: \(error.localizedDescription)")
            }
        }
    }
    
    private func propagarAlteracoesParaSessoesFuturas(regraAtualizada: FixedSession, userId: String) async throws {
        let calendar = Calendar.current
        let inicioDoDiaAtual = calendar.startOfDay(for: Date())
        
        let sessoes = try await sessionRepository.fetchSessoes(userId: userId)
        let sessoesFilhasFuturas = sessoes.filter { $0.fixedSessionID == regraAtualizada.id && $0.sessionDate >= inicioDoDiaAtual }
        
        for sessao in sessoesFilhasFuturas {
            var sessaoModificada = sessao
            sessaoModificada.startTime = regraAtualizada.horaInicio
            sessaoModificada.modality = regraAtualizada.modalidade
            
            var components = calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: sessao.sessionDate)
            components.weekday = regraAtualizada.diaDaSemana
            
            if let novaData = calendar.date(from: components) { sessaoModificada.sessionDate = novaData }
            try await sessionRepository.atualizarSessao(sessaoModificada, userId: userId)
        }
    }
    
    func deletarSessao(userId: String) {
        Task {
            do {
                switch itemToEdit {
                case .fixa(let fixa):
                    try await fixedSessionRepository.deletarSessaoFixa(id: fixa.id, userId: userId)
                    let sessoes = try await sessionRepository.fetchSessoes(userId: userId)
                    let hoje = Calendar.current.startOfDay(for: Date())
                    
                    for sessao in sessoes.filter({ $0.fixedSessionID == fixa.id && $0.sessionDate >= hoje }) {
                        try await sessionRepository.deletarSessao(id: sessao.id, userId: userId)
                    }
                case .avulsa(let avulsa):
                    try await sessionRepository.deletarSessao(id: avulsa.id, userId: userId)
                }
            } catch {
                print("Erro ao deletar sessão: \(error.localizedDescription)")
            }
        }
    }    
}
