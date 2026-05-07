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
        
    /// Avalia a mudança de status de um paciente e propaga (em cascata) os efeitos para a sua agenda.
    /// - Inativo: Varre a base e cancela automaticamente projeções futuras não realizadas.
    /// - Ativo: Inicia a projeção de contratos para repovoar os horários na agenda do psicólogo.
    func sincronizarSessoesPorStatus(
        do paciente: Patient,
        regrasFixas: [FixedSession],
        sessionRepository: SessionRepositoryProtocol
    ) {
        let hoje = Calendar.current.startOfDay(for: Date())
        let todasSessoes = sessionRepository.fetchSessoes()
        
        // Note: Em produção, substitua esses 'prints' de feedback pelo Logger
        // nativo do sistema (import os) para não sobrecarregar o console em release.
        
        if paciente.status == .inativo {
            // Fluxo de Inativação: Cancelamento em massa
            for sessao in todasSessoes where sessao.pacienteID == paciente.id {
                if sessao.dataDaSessão >= hoje && sessao.status == .agendada {
                    var sessaoCancelada = sessao
                    sessaoCancelada.status = .cancelada
                    sessionRepository.atualizarSessao(sessaoCancelada)
                }
            }
            print("🚫 Paciente inativado. Sessões futuras foram canceladas na agenda.")
            
        } else if paciente.status == .ativo {
            // Fluxo de Reativação: Repovoamento de agenda
            let dataFim = ultimoDiaDoProximoMes(aPartirDe: hoje)
            
            for regra in regrasFixas where regra.pacienteID == paciente.id {
                let sessoesParaGerar = gerarSessoes(para: regra, dataInicio: hoje, dataFim: dataFim)
                
                for novaSessao in sessoesParaGerar {
                    
                    // Princípio de Idempotência: Garante que a operação não criará sessões duplicadas
                    // caso a função seja chamada múltiplas vezes inadvertidamente.
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
