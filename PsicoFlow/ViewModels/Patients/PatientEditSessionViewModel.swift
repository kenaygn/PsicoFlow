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
    
    @Published var selectedModalidade: Modalidade
    @Published var selectedTime: String
    
    // Estados específicos que variam conforme o tipo de sessão
    @Published var selectedWeekday: Int = 1
    @Published var selectedDate: Date = Date()
    
    private let fixedSessionRepository: FixedSessionRepositoryProtocol
    private let sessionRepository: SessionRepositoryProtocol
    
    private let availabilityService: AgendaAvailabilityService
    
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
        
        self.availabilityService = AgendaAvailabilityService(
            fixedSessionRepository: fixedSessionRepository,
            sessionRepository: sessionRepository
        )
        
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
    
    /// Delega o cálculo de horários livres para o Serviço de Domínio.
    var horariosLivres: [String] {
        switch itemToEdit {
        case .fixa(let fixaAtual):
            return availabilityService.horariosLivresParaContrato(
                diaDaSemana: selectedWeekday,
                ignorandoContratoID: fixaAtual.id
            )
            
        case .avulsa(let avulsaAtual):
            return availabilityService.horariosLivresParaSessaoAvulsa(
                data: selectedDate,
                ignorandoSessaoID: avulsaAtual.id,
                derivadaDeContratoID: avulsaAtual.sessaoFixaID
            )
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
            propagarAlteracoesParaSessoesFuturas(regraAtualizada: atualizada)
            
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
    
    /// Aplica as alterações de horário, modalidade e dia da semana de um contrato (Sessão Fixa)
    /// a todas as sessões pontuais vinculadas a ele, garantindo a integridade do histórico passado.
    private func propagarAlteracoesParaSessoesFuturas(regraAtualizada: FixedSession) {
        let calendar = Calendar.current
        let inicioDoDiaAtual = calendar.startOfDay(for: Date())
        
        let sessoesFilhasFuturas = sessionRepository.fetchSessoes().filter {
            $0.sessaoFixaID == regraAtualizada.id &&
            $0.dataDaSessão >= inicioDoDiaAtual
        }
        print(sessoesFilhasFuturas)
        
        for sessao in sessoesFilhasFuturas {
            var sessaoModificada = sessao
            
            sessaoModificada.horaInicio = regraAtualizada.horaInicio
            sessaoModificada.modalidade = regraAtualizada.modalidade
            
            var components = calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: sessao.dataDaSessão)
            components.weekday = regraAtualizada.diaDaSemana
            
            if let novaDataCorreta = calendar.date(from: components) {
                sessaoModificada.dataDaSessão = novaDataCorreta
            }
            
            sessionRepository.atualizarSessao(sessaoModificada)
        }
    }
    
    /// Exclui a sessão selecionada. Se for um contrato (Fixa), exclui também
    /// as projeções futuras, mantendo o histórico passado intacto.
    func deletarSessao() {
        switch itemToEdit {
        case .fixa(let fixa):
            // 1. Deleta a regra matriz
            fixedSessionRepository.deletarSessaoFixa(id: fixa.id)
            
            // 2. Busca e deleta as filhas futuras
            let hoje = Calendar.current.startOfDay(for: Date())
            let sessoesFuturas = sessionRepository.fetchSessoes().filter {
                $0.sessaoFixaID == fixa.id && $0.dataDaSessão >= hoje
            }
            
            for sessao in sessoesFuturas {
                sessionRepository.deletarSessao(id: sessao.id)
            }
            print("🗑️ Sessão Fixa e suas projeções futuras foram excluídas.")
            
        case .avulsa(let avulsa):
            // Deleta apenas a sessão única
            sessionRepository.deletarSessao(id: avulsa.id)
            print("🗑️ Sessão Avulsa excluída.")
        }
    }
}
