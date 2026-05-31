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
    
    private let patientRepository: PatientRepositoryProtocol
    private let fixedSessionRepository: FixedSessionRepositoryProtocol
    private let sessionRepository: SessionRepositoryProtocol
    
    // Agora o serviço recebe os repositórios necessários para fazer as checagens
    init(
        patientRepository: PatientRepositoryProtocol,
        fixedSessionRepository: FixedSessionRepositoryProtocol,
        sessionRepository: SessionRepositoryProtocol
    ) {
        self.patientRepository = patientRepository
        self.fixedSessionRepository = fixedSessionRepository
        self.sessionRepository = sessionRepository
    }
    
    /// Varre os contratos ativos e garante que a linha do tempo do calendário
    /// esteja preenchida até o último dia do mês seguinte, evitando duplicações.
    func projetarSessoesFuturas() {
        let dataFim = ultimoDiaDoProximoMes() // Chama a função local
        let regrasFixas = fixedSessionRepository.fetchSessoesFixas()
        let pacientesAtivos = patientRepository.fetchPacientes().filter { $0.status == .ativo }
        let sessoesExistentes = sessionRepository.fetchSessoes()
        
        var totalNovasGeradas = 0
        
        for regra in regrasFixas {
            // Só gera sessões se o paciente ainda estiver ativo na clínica
            if pacientesAtivos.contains(where: { $0.id == regra.pacienteID }) {
                
                let sessoesProjetadas = gerarSessoes(para: regra, dataFim: dataFim) // Chama a função local
                
                // Filtro Anti-Duplicação: Garante que não vamos salvar a mesma sessão duas vezes
                for sessaoNova in sessoesProjetadas {
                    let jaExiste = sessoesExistentes.contains {
                        $0.sessaoFixaID == regra.id &&
                        Calendar.current.isDate($0.dataDaSessão, inSameDayAs: sessaoNova.dataDaSessão)
                    }
                    
                    if !jaExiste {
                        sessionRepository.salvarSessao(sessaoNova)
                        totalNovasGeradas += 1
                    }
                }
            }
        }
        
        if totalNovasGeradas > 0 {
            print("📅 [Session Generator] \(totalNovasGeradas) novas sessões recorrentes foram adicionadas à agenda.")
        }
    }
    
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
