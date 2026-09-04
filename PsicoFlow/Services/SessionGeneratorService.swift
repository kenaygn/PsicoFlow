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
    
    // MARK: - TODO: MIGRAÇÃO PARA BACKEND (FIREBASE CLOUD FUNCTIONS)
    // TODO: [V2.0] A projeção de sessões na agenda também está rodando no "Client-Side".
    // Para garantir escalabilidade, notificações push precisas e não depender do
    // ciclo de vida do app no iPhone do usuário, mover essa rotina para um Cron Job no Firebase.
    
    /// Varre os contratos ativos e garante que a linha do tempo do calendário
    /// esteja preenchida até o último dia do mês seguinte, evitando duplicações.
    /// Também remove sessões futuras de pacientes que foram inativados.
    func projetarSessoesFuturas(userId: String) async throws {
        let hoje = Calendar.current.startOfDay(for: Date())
        let dataFim = ultimoDiaDoProximoMes() // Chama a função local
        
        // Buscas assíncronas usando o userId
        let regrasFixas = try await fixedSessionRepository.fetchSessoesFixas(userId: userId)
        let todosPacientes = try await patientRepository.fetchPacientes(userId: userId)
        
        // Pega apenas os IDs dos pacientes que continuam ativos
        let pacientesAtivosIDs = todosPacientes.filter { $0.status == .active }.map { $0.id }
        
        var sessoesExistentes = try await sessionRepository.fetchSessoes(userId: userId)
        
        //- 1. PASSO DE LIMPEZA (Cleanup)
        // Deleta sessões futuras geradas por contrato caso o paciente não esteja mais ativo
        var totalRemovidas = 0
        
        for sessao in sessoesExistentes {
            // Só apaga se for no futuro E se for fruto de um contrato (sessaoFixaID != nil)
            if sessao.dataDaSessao >= hoje && sessao.sessaoFixaID != nil {
                if !pacientesAtivosIDs.contains(sessao.pacienteID) {
                    try await sessionRepository.deletarSessao(id: sessao.id, userId: userId)
                    totalRemovidas += 1
                }
            }
        }
        
        if totalRemovidas > 0 {
            print("🧹 [Session Generator] \(totalRemovidas) sessões futuras removidas de pacientes inativos.")
            // Atualiza a variável com a lista limpa para não bugar a geração abaixo
            sessoesExistentes = try await sessionRepository.fetchSessoes(userId: userId)
        }
        
        //- 2. PASSO DE GERAÇÃO (Projeção)
        var totalNovasGeradas = 0
        
        for regra in regrasFixas {
            // Só gera sessões se o paciente AINDA estiver na lista de ativos
            if pacientesAtivosIDs.contains(regra.pacienteID) {
                
                let sessoesProjetadas = gerarSessoes(para: regra, dataFim: dataFim)
                
                // Filtro Anti-Duplicação
                for sessaoNova in sessoesProjetadas {
                    let jaExiste = sessoesExistentes.contains {
                        $0.sessaoFixaID == regra.id &&
                        Calendar.current.isDate($0.dataDaSessao, inSameDayAs: sessaoNova.dataDaSessao)
                    }
                    
                    if !jaExiste {
                        try await sessionRepository.salvarSessao(sessaoNova, userId: userId)
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
                    dataDaSessao: dataAtual,
                    status: .agendada,
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
