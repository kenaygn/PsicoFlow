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
class EditSessionViewModel: ObservableObject {
    
    // MARK: - Properties
    
    let itemToEdit: EditSessionItem
    let nomePaciente: String
    
    @Published var selectedModalidade: Modalidade
    @Published var selectedTime: String
    
    // Estados específicos que variam conforme o tipo de sessão
    @Published var selectedWeekday: Int = 1
    @Published var selectedDate: Date = Date()
    
    private let fixedSessionRepository: FixedSessionRepositoryProtocol
    private let sessionRepository: SessionRepositoryProtocol
    
    // Note: Esta matriz está fixada para o MVP. Em versões futuras, o ideal é
    // buscar este array das "Configurações de Expediente" do psicólogo logado.
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
        
        // Inicialização condicional baseada no tipo de payload recebido
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
        
    var isFixa: Bool {
        if case .fixa = itemToEdit { return true }
        return false
    }
    
    /// Algoritmo de detecção de disponibilidade.
    /// Avalia a matriz de `todosHorarios` contra o repositório, filtrando colisões
    /// de acordo com a natureza da sessão (recorrente ou única).
    var horariosLivres: [String] {
        switch itemToEdit {
            
        case .fixa(let fixaAtual):
            // Regra Contratual: Contratos só competem com outros contratos no mesmo dia da semana.
            let outrasRegrasNoMesmoDia = fixedSessionRepository.fetchSessoesFixas().filter {
                $0.diaDaSemana == selectedWeekday &&
                $0.id != fixaAtual.id // Exclusão do próprio ID para evitar auto-bloqueio
            }
            let ocupados = outrasRegrasNoMesmoDia.map { $0.horaInicio }
            return todosHorarios.filter { !ocupados.contains($0) }
            
        case .avulsa(let avulsaAtual):
            // Regra Pontual: Eventos únicos competem tanto com contratos estabelecidos quanto com outras avulsas.
            let weekdayDaData = Calendar.current.component(.weekday, from: selectedDate)
            
            let regrasFixas = fixedSessionRepository.fetchSessoesFixas().filter {
                $0.diaDaSemana == weekdayDaData &&
                $0.id != avulsaAtual.sessaoFixaID // Ignora a regra matriz caso a sessão derive de um contrato
            }
            
            let outrasAvulsas = sessionRepository.fetchSessoes().filter {
                Calendar.current.isDate($0.dataDaSessão, inSameDayAs: selectedDate) &&
                $0.status != .cancelada &&
                $0.id != avulsaAtual.id // Exclusão do próprio ID
            }
            
            let ocupadosFixas = regrasFixas.map { $0.horaInicio }
            let ocupadosAvulsas = outrasAvulsas.map { $0.horaInicio }
            let todosOcupados = ocupadosFixas + ocupadosAvulsas
            
            return todosHorarios.filter { !todosOcupados.contains($0) }
        }
    }
        
    /// Garante a integridade dos dados selecionados caso o usuário mude o dia/data
    /// e o horário anteriormente selecionado fique indisponível.
    func atualizarSelecaoDeHorario() {
        if !horariosLivres.contains(selectedTime) {
            selectedTime = horariosLivres.first ?? ""
        }
    }
    
    /// Persiste as modificações no respectivo repositório.
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
            
            // Restaura o status para agendada caso o usuário esteja reagendando ativamente uma sessão adiada
            if atualizada.status == .adiada {
                atualizada.status = .agendada
            }
            sessionRepository.atualizarSessao(atualizada)
        }
    }
}
