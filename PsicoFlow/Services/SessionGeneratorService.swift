//
//  SessionGeneratorService.swift
//  PsicoFlow
//
//  Created by Kenay on 13/04/26.
//

import Foundation

/// Serviço de domínio responsável por gerar sessões com base em regras de sessões fixas
/// e retira as sessoes de pacientes inativos mas caso seja reativado as sessoes sao recriadas
class SessionGeneratorService {
        
    /// Projeta e gera um array de instâncias de sessões baseadas em um contrato (FixedSession),
    /// iterando dia a dia dentro de um limite de tempo estabelecido.
    func gerarSessoes(para regra: FixedSession, dataInicio: Date = Date(), dataFim: Date) -> [Session] {
        let calendar = Calendar.current
        var sessoesGeradas: [Session] = []
        
        var dataAtual = dataInicio
        
        while dataAtual <= dataFim {
            let diaDaSemanaAtual = calendar.component(.weekday, from: dataAtual)
            
            // Se o dia do calendário corresponder ao dia estipulado no contrato
            if diaDaSemanaAtual == regra.diaDaSemana {
                
                let novaSessao = Session(
                    id: UUID().uuidString,
                    psicologoID: regra.psicologoID,
                    pacienteID: regra.pacienteID,
                    sessaoFixaID: regra.id,
                    dataDaSessão: dataAtual,
                    status: .agendada, // Por regra de negócio, projeções futuras nascem pendentes
                    modalidade: regra.modalidade,
                    horaInicio: regra.horaInicio
                )
                
                sessoesGeradas.append(novaSessao)
            }
            
            // Avança iterativamente
            guard let proximoDia = calendar.date(byAdding: .day, value: 1, to: dataAtual) else { break }
            dataAtual = proximoDia
        }
        
        return sessoesGeradas
    }
        
    /// Calcula o limite temporal padrão do sistema para a geração de lotes contínuos
    /// (O último dia do mês seguinte).
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
