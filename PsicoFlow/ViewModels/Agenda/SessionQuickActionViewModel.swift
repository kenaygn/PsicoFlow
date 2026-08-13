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
    private let fixedSessionRepository: FixedSessionRepositoryProtocol
    
    private let availabilityService: AgendaAvailabilityService
    
    @Published var novaData: Date
    @Published var novaHoraStr: String
    
    // Transformamos em @Published para receber os dados do Firebase de forma assíncrona
    @Published var horariosLivres: [String] = []
    
    init(
        sessao: Session,
        sessionRepository: SessionRepositoryProtocol = SessionFirebaseRepository(),
        fixedSessionRepository: FixedSessionRepositoryProtocol = FixedSessionFirebaseRepository()
    ) {
        self.sessao = sessao
        self.sessionRepository = sessionRepository
        self.fixedSessionRepository = fixedSessionRepository
        
        self.availabilityService = AgendaAvailabilityService(
            fixedSessionRepository: fixedSessionRepository,
            sessionRepository: sessionRepository
        )
        
        self._novaData = Published(initialValue: sessao.dataDaSessao)
        self._novaHoraStr = Published(initialValue: sessao.horaInicio)
    }
    
    /// Delega o cálculo de horários livres para o serviço centralizado de forma assíncrona,
    /// ignorando a própria sessão atual para permitir que o utilizador mantenha o mesmo horário
    /// caso esteja apenas a mudar a data.
    func carregarHorariosLivres(userId: String) {
        guard !userId.isEmpty else { return }
        
        Task {
            do {
                let livres = try await availabilityService.horariosLivresParaSessaoAvulsa(
                    data: novaData,
                    ignorandoSessaoID: sessao.id,
                    derivadaDeContratoID: sessao.sessaoFixaID,
                    userId: userId
                )
                
                self.horariosLivres = livres
                self.ajustarHorarioSeNecessario()
            } catch {
                print("Erro ao calcular horários livres: \(error.localizedDescription)")
            }
        }
    }
    
    /// Retorna a lista de horários disponíveis formatada para exibição segura na UI.
    /// Caso o horário originalmente selecionado já esteja ocupado ou fora da grade padrão,
    /// ele é injetado temporariamente para evitar falhas de seleção no Picker nativo.
    var horariosParaOPicker: [String] {
        var listaSegura = horariosLivres
        
        // Evita piscar a tela antes da primeira busca
        if listaSegura.isEmpty && !novaHoraStr.isEmpty {
            return [novaHoraStr]
        }
        
        if !novaHoraStr.isEmpty && !listaSegura.contains(novaHoraStr) {
            listaSegura.append(novaHoraStr)
            listaSegura.sort()
        }
        
        return listaSegura
    }
    
    /// Valida e ajusta automaticamente o horário selecionado caso o usuário altere
    /// a data alvo e o slot anteriormente preenchido fique indisponível.
    func ajustarHorarioSeNecessario() {
        if !horariosLivres.isEmpty && !horariosLivres.contains(novaHoraStr) {
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
