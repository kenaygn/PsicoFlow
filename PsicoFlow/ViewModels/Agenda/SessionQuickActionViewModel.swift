//
//  SessionQuickActionViewModel.swift
//  PsicoFlow
//
//  Created by Kenay on 13/04/26.
//

import Foundation
import Combine

class SessionQuickActionViewModel: ObservableObject {
    
    // MARK: - Dependências
    let sessao: Session
    private let sessionRepository: SessionRepositoryProtocol
    
    private let todosHorarios: [String] = [
        "07:00", "08:00", "09:00", "10:00", "11:00", "12:00",
        "13:00", "14:00", "15:00", "16:00", "17:00", "18:00", "19:00", "20:00", "21:00", "22:00"
    ]
    
    // MARK: - Estados de Dados (@Published)
    @Published var novaData: Date
    @Published var novaHoraStr: String
    
    // MARK: - Inicialização (Injeção de Dependência)
    init(sessao: Session, sessionRepository: SessionRepositoryProtocol = MockSessionRepository()) {
        self.sessao = sessao
        self.sessionRepository = sessionRepository
        
        // Inicializa com os dados atuais da sessão
        self._novaData = Published(initialValue: sessao.dataDaSessão)
        self._novaHoraStr = Published(initialValue: sessao.horaInicio)
    }
    
    // MARK: - Regras de Negócio
    
    var horariosLivres: [String] {
        let sessoesNoMesmoDia = sessionRepository.fetchSessoes().filter {
            Calendar.current.isDate($0.dataDaSessão, inSameDayAs: novaData) &&
            $0.status != .cancelada &&
            $0.id != sessao.id // Ignora a própria sessão que estamos reagendando
        }
        let ocupados = sessoesNoMesmoDia.map { $0.horaInicio }
        return todosHorarios.filter { !ocupados.contains($0) }
    }
    
    var horariosParaOPicker: [String] {
        var listaSegura = horariosLivres
        
        if !novaHoraStr.isEmpty && !listaSegura.contains(novaHoraStr) {
            listaSegura.append(novaHoraStr)
            listaSegura.sort() // Reordena para o horário voltar para a posição correta (ex: 14:00 depois de 13:00)
        }
        
        return listaSegura
    }
    
    // Trava de segurança para atualizar a seleção caso o dia mude
    func ajustarHorarioSeNecessario() {
        if !horariosLivres.contains(novaHoraStr) {
            novaHoraStr = horariosLivres.first ?? ""
        }
    }
    
    // Pega o dia (Date) e junta com a string "HH:mm" para devolver pro banco
    func obterDataFinal() -> Date {
        let partes = novaHoraStr.split(separator: ":")
        guard partes.count == 2, let hora = Int(partes[0]), let minuto = Int(partes[1]) else { return novaData }
        return Calendar.current.date(bySettingHour: hora, minute: minuto, second: 0, of: novaData) ?? novaData
    }
}
