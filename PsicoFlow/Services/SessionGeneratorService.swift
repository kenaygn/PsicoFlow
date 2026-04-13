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
}
