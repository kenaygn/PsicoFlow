//
//  PatientEditSessionViewModel.swift
//  PsicoFlow
//
//  Created by Kenay on 05/05/26.
//

import Foundation
import Combine

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

class EditSessionViewModel: ObservableObject {
    let itemToEdit: EditSessionItem
    let nomePaciente: String
    
    // Estados editáveis universais
    @Published var selectedModalidade: Modalidade
    @Published var selectedTime: String
    
    // Estados específicos
    @Published var selectedWeekday: Int = 1
    @Published var selectedDate: Date = Date()
    
    // Repositórios
    private let fixedSessionRepository: FixedSessionRepositoryProtocol
    private let sessionRepository: SessionRepositoryProtocol
    
    let todosHorarios: [String] = [
        "07:00", "08:00", "09:00", "10:00", "11:00", "12:00",
        "13:00", "14:00", "15:00", "16:00", "17:00", "18:00", "19:00", "20:00", "21:00", "22:00"
    ]
    
    init(
        item: EditSessionItem,
        nomePaciente: String,
        fixedSessionRepository: FixedSessionRepositoryProtocol = MockFixedSessionRepository(),
        sessionRepository: SessionRepositoryProtocol = MockSessionRepository()
    ) {
        self.itemToEdit = item
        self.nomePaciente = nomePaciente
        self.fixedSessionRepository = fixedSessionRepository
        self.sessionRepository = sessionRepository
        
        // 👇 2. Preenchemos os campos dependendo do que o usuário clicou
        switch item {
        case .fixa(let fixa):
            self.selectedModalidade = fixa.modalidade
            self.selectedWeekday = fixa.diaDaSemana
            self.selectedTime = fixa.horaInicio
        case .avulsa(let avulsa):
            self.selectedModalidade = avulsa.modalidade
            self.selectedDate = avulsa.dataDaSessão
            self.selectedTime = avulsa.horaInicio
        }
    }
    
    // Helper para a View saber o que renderizar
    var isFixa: Bool {
        if case .fixa = itemToEdit { return true }
        return false
    }
    
    var horariosLivres: [String] {
        switch itemToEdit {
            
        case .fixa(let fixaAtual):
            // 1. REGRA FIXA: Só é bloqueada por outras Regras Fixas
            let outrasRegrasNoMesmoDia = fixedSessionRepository.fetchSessoesFixas().filter {
                $0.diaDaSemana == selectedWeekday &&
                $0.id != fixaAtual.id // IMPEDE QUE ELA BLOQUEIE A SI MESMA!
            }
            let ocupados = outrasRegrasNoMesmoDia.map { $0.horaInicio }
            return todosHorarios.filter { !ocupados.contains($0) }
            
        case .avulsa(let avulsaAtual):
            // 2. SESSÃO AVULSA: É bloqueada por Regras Fixas E por outras Sessões Avulsas
            let weekdayDaData = Calendar.current.component(.weekday, from: selectedDate)
            
            // Pega as regras fixas desse dia da semana
            let regrasFixas = fixedSessionRepository.fetchSessoesFixas().filter {
                $0.diaDaSemana == weekdayDaData &&
                $0.id != avulsaAtual.sessaoFixaID // Se esta avulsa nasceu de uma regra fixa, a regra mãe não deve bloqueá-la
            }
            
            // Pega outras sessões avulsas nesse exato dia
            let outrasAvulsas = sessionRepository.fetchSessoes().filter {
                Calendar.current.isDate($0.dataDaSessão, inSameDayAs: selectedDate) &&
                $0.status != .cancelada &&
                $0.id != avulsaAtual.id // IMPEDE QUE ELA BLOQUEIE A SI MESMA!
            }
            
            let ocupadosFixas = regrasFixas.map { $0.horaInicio }
            let ocupadosAvulsas = outrasAvulsas.map { $0.horaInicio }
            let todosOcupados = ocupadosFixas + ocupadosAvulsas
            
            return todosHorarios.filter { !todosOcupados.contains($0) }
        }
    }
    
    func atualizarSelecaoDeHorario() {
        if !horariosLivres.contains(selectedTime) {
            selectedTime = horariosLivres.first ?? ""
        }
    }
    
    func salvarEdicao() {
        switch itemToEdit {
        case .fixa(let fixa):
            var atualizada = fixa
            atualizada.modalidade = selectedModalidade
            atualizada.diaDaSemana = selectedWeekday
            atualizada.horaInicio = selectedTime
            fixedSessionRepository.atualizarSessaoFixa(atualizada)
            
        case .avulsa(let avulsa):
            var atualizada = avulsa
            atualizada.modalidade = selectedModalidade
            atualizada.dataDaSessão = selectedDate
            atualizada.horaInicio = selectedTime
            // 👇 Se o usuário mudou a data ou hora, talvez o status volte para agendada!
            if atualizada.status == .adiada { atualizada.status = .agendada }
            sessionRepository.atualizarSessao(atualizada)
        }
    }
}
