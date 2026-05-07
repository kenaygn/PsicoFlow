//
//  SessionGeneratorService.swift
//  PsicoFlow
//
//  Created by Kenay on 13/04/26.
//

import Foundation

class SessionGeneratorService {
    
    // Gera instâncias de sessões baseadas na regra (FixedSession)
    func gerarSessoes(para regra: FixedSession, dataInicio: Date = Date(), dataFim: Date) -> [Session] {
        let calendar = Calendar.current
        var sessoesGeradas: [Session] = []
        
        // Vamos procurar a data base iterando dia por dia
        var dataAtual = dataInicio
        
        // Loop até a data atual ultrapassar a data limite
        while dataAtual <= dataFim {
            let diaDaSemanaAtual = calendar.component(.weekday, from: dataAtual)
            
            // Se o dia da semana bater com a regra do paciente (Ex: 2 = Segunda-feira)
            if diaDaSemanaAtual == regra.diaDaSemana {
                
                // Cria a instância real do evento
                let novaSessao = Session(
                    id: UUID().uuidString,
                    psicologoID: regra.psicologoID,
                    pacienteID: regra.pacienteID,
                    sessaoFixaID: regra.id, 
                    dataDaSessão: dataAtual,
                    status: .agendada, // Nasce sempre como agendada
                    modalidade: regra.modalidade,
                    horaInicio: regra.horaInicio
                )
                
                sessoesGeradas.append(novaSessao)
            }
            
            // Avança 1 dia
            guard let proximoDia = calendar.date(byAdding: .day, value: 1, to: dataAtual) else { break }
            dataAtual = proximoDia
        }
        
        return sessoesGeradas
    }
    
    // Helper: Calcula o último dia do PRÓXIMO mês
    func ultimoDiaDoProximoMes(aPartirDe data: Date = Date()) -> Date {
        let calendar = Calendar.current
        guard let mesQueVem = calendar.date(byAdding: .month, value: 1, to: data),
              let inicioDoMesQueVem = calendar.date(from: calendar.dateComponents([.year, .month], from: mesQueVem)),
              let fimDoMesQueVem = calendar.date(byAdding: DateComponents(month: 1, day: -1), to: inicioDoMesQueVem) else {
            return Date()
        }
        return fimDoMesQueVem
    }
    
        func sincronizarSessoesPorStatus(
            do paciente: Patient,
            regrasFixas: [FixedSession],
            sessionRepository: SessionRepositoryProtocol
        ) {
            let hoje = Calendar.current.startOfDay(for: Date())
            let todasSessoes = sessionRepository.fetchSessoes()
            
            if paciente.status == .inativo {
                // 1. O paciente foi DESATIVADO: Varre a agenda e cancela sessões futuras
                for sessao in todasSessoes where sessao.pacienteID == paciente.id {
                    // Pega apenas as sessões de hoje pra frente que ainda não foram realizadas
                    if sessao.dataDaSessão >= hoje && sessao.status == .agendada {
                        var sessaoCancelada = sessao
                        sessaoCancelada.status = .cancelada
                        sessionRepository.atualizarSessao(sessaoCancelada)
                    }
                }
                print("🚫 Paciente inativado. Sessões futuras foram canceladas na agenda.")
                
            } else if paciente.status == .ativo {
                // 2. O paciente foi ATIVADO: Gera as sessões que estão faltando
                let dataFim = ultimoDiaDoProximoMes(aPartirDe: hoje)
                
                // Procura as regras fixas (contratos) deste paciente
                for regra in regrasFixas where regra.pacienteID == paciente.id {
                    let sessoesParaGerar = gerarSessoes(para: regra, dataInicio: hoje, dataFim: dataFim)
                    
                    for novaSessao in sessoesParaGerar {
                        // Evita criar duplicatas caso a sessão já exista naquele dia
                        let jaExiste = todasSessoes.contains {
                            $0.sessaoFixaID == regra.id &&
                            Calendar.current.isDate($0.dataDaSessão, inSameDayAs: novaSessao.dataDaSessão)
                        }
                        
                        if !jaExiste {
                            sessionRepository.salvarSessao(novaSessao)
                        }
                    }
                }
                print("✅ Paciente ativado. Novas sessões geradas para a agenda!")
            }
        }
}
