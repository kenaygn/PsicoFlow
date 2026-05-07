//
//  SessionQuickActionViewModel.swift
//  PsicoFlow
//
//  Created by Kenay on 13/04/26.
//

import Foundation
import Combine

/// ViewModel responsável pelo controle de estado e regras de negócio do modal de Ações Rápidas.
/// Isola a lógica de resolução de conflitos e manipulação de datas para garantir que a View
/// permaneça focada apenas na renderização da interface e animações.
class SessionQuickActionViewModel: ObservableObject {
        
    let sessao: Session
    private let sessionRepository: SessionRepositoryProtocol
    
    // Note: Assim como na HomeViewModel e EditSessionViewModel, esta matriz de horários deve
    // ser externalizada para uma configuração global da clínica em fases futuras do projeto.
    private let todosHorarios: [String] = [
        "07:00", "08:00", "09:00", "10:00", "11:00", "12:00",
        "13:00", "14:00", "15:00", "16:00", "17:00", "18:00", "19:00", "20:00", "21:00", "22:00"
    ]
        
    @Published var novaData: Date
    @Published var novaHoraStr: String
        
    init(sessao: Session, sessionRepository: SessionRepositoryProtocol = MockSessionRepository()) {
        self.sessao = sessao
        self.sessionRepository = sessionRepository
        
        self._novaData = Published(initialValue: sessao.dataDaSessão)
        self._novaHoraStr = Published(initialValue: sessao.horaInicio)
    }
        
    /// Filtra a matriz de horários padrão, removendo os slots já ocupados no dia selecionado.
    var horariosLivres: [String] {
        let sessoesNoMesmoDia = sessionRepository.fetchSessoes().filter {
            Calendar.current.isDate($0.dataDaSessão, inSameDayAs: novaData) &&
            $0.status != .cancelada &&
            $0.id != sessao.id // Ignora a própria sessão durante reagendamentos
        }
        let ocupados = sessoesNoMesmoDia.map { $0.horaInicio }
        return todosHorarios.filter { !ocupados.contains($0) }
    }
    
    /// Retorna a lista de horários disponíveis formatada para exibição segura na UI.
    /// Caso o horário originalmente selecionado já esteja ocupado ou fora da grade padrão,
    /// ele é injetado temporariamente para evitar falhas de seleção no Picker nativo.
    var horariosParaOPicker: [String] {
        var listaSegura = horariosLivres
        
        if !novaHoraStr.isEmpty && !listaSegura.contains(novaHoraStr) {
            listaSegura.append(novaHoraStr)
            listaSegura.sort()
        }
        
        return listaSegura
    }
        
    /// Valida e ajusta automaticamente o horário selecionado caso o usuário altere
    /// a data alvo e o slot anteriormente preenchido fique indisponível.
    func ajustarHorarioSeNecessario() {
        if !horariosLivres.contains(novaHoraStr) {
            novaHoraStr = horariosLivres.first ?? ""
        }
    }
    
    /// Combina a data base selecionada no calendário com a string de horário para compor o timestamp final.
    func obterDataFinal() -> Date {
        let partes = novaHoraStr.split(separator: ":")
        guard partes.count == 2, let hora = Int(partes[0]), let minuto = Int(partes[1]) else { return novaData }
        
        return Calendar.current.date(bySettingHour: hora, minute: minuto, second: 0, of: novaData) ?? novaData
    }
}
