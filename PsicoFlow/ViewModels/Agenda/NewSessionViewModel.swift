//
//  NewSessionViewModel.swift
//  PsicoFlow
//
//  Created by Kenay on 13/04/26.
//

import Foundation
import Combine
import os // Preparação futura para Logger

/// ViewModel responsável pela lógica de criação de novos agendamentos.
/// Orquestra a seleção de pacientes, detecção de horários livres e delega
/// a geração em lote de contratos (FixedSession) para o SessionGeneratorService.
class NewSessionViewModel: ObservableObject {
    
    private let patientRepository: PatientRepositoryProtocol
    private let sessionRepository: SessionRepositoryProtocol
    private let fixedSessionRepository: FixedSessionRepositoryProtocol
    
    private let generatorService: SessionGeneratorService
    private let availabilityService: AgendaAvailabilityService
    
    
    @Published var pacientesDisponiveis: [Patient] = []
    @Published var pacienteSelecionadoID: String = ""
    @Published var isFixedSession: Bool = false
    @Published var selectedDate: Date = Date()
    @Published var selectedWeekday: Int = Calendar.current.component(.weekday, from: Date())
    @Published var selectedTime: String = "08:00"
    @Published var selectedModalidade: Modalidade = .presencial
    
    init(
        dataSugerida: Date = Date(),
        horarioSugerido: String = "08:00",
        patientRepository: PatientRepositoryProtocol = MockPatientRepository(),
        sessionRepository: SessionRepositoryProtocol = MockSessionRepository(),
        fixedSessionRepository: FixedSessionRepositoryProtocol = MockFixedSessionRepository()
    ) {
        self.patientRepository = patientRepository
        self.sessionRepository = sessionRepository
        self.fixedSessionRepository = fixedSessionRepository
        
        // Aplica as sugestões passadas pela tela anterior (Atalho de agendamento)
        self.selectedDate = dataSugerida
        self.selectedTime = horarioSugerido
        self.selectedWeekday = Calendar.current.component(.weekday, from: dataSugerida)
        
        self.availabilityService = AgendaAvailabilityService(
            fixedSessionRepository: fixedSessionRepository,
            sessionRepository: sessionRepository
        )
        
        self.generatorService = SessionGeneratorService(
            patientRepository: patientRepository,
            fixedSessionRepository: fixedSessionRepository,
            sessionRepository: sessionRepository
        )
        
        carregarPacientes()
    }
    
    var horaFormatada: String {
        return selectedTime
    }
    
    /// Delega o cálculo complexo de horários livres para o Serviço de Domínio
    var horariosLivres: [String] {
        if isFixedSession {
            return availabilityService.horariosLivresParaContrato(diaDaSemana: selectedWeekday)
        } else {
            return availabilityService.horariosLivresParaSessaoAvulsa(data: selectedDate)
        }
    }
    
    private func carregarPacientes() {
        self.pacientesDisponiveis = patientRepository.fetchPacientes().filter { $0.status == .ativo }
        if let primeiro = pacientesDisponiveis.first {
            self.pacienteSelecionadoID = primeiro.id
        }
    }
    
    /// Garante a integridade da UI selecionando automaticamente o primeiro horário livre
    /// caso o usuário navegue para um dia onde o horário atual esteja ocupado.
    func atualizarSelecaoDeHorario() {
        if !horariosLivres.contains(selectedTime) {
            selectedTime = horariosLivres.first ?? ""
        }
    }
    
    /// Constrói e persiste as sessões com base na modalidade escolhida (Contrato ou Avulsa).
    func salvarSessao() {
        guard let paciente = pacientesDisponiveis.first(where: { $0.id == pacienteSelecionadoID }) else { return }
        
        // Note: Em produção, substitua os comandos 'print' por um sistema nativo de log,
        // como o 'os.Logger', para evitar vazamento de memória e garantir rastreabilidade.
        // Ex: Logger().info("Regra criada...")
        
        if isFixedSession {
            
            // 1. Cria a diretriz do contrato
            let novaRegra = FixedSession(
                id: "fix_\(UUID().uuidString)",
                psicologoID: paciente.psicologoID,
                pacienteID: paciente.id,
                diaDaSemana: selectedWeekday,
                horaInicio: horaFormatada,
                modalidade: selectedModalidade
            )
            
            fixedSessionRepository.salvarSessaoFixa(novaRegra)
            
            // 2. Delega a projeção do calendário para o Service
            let dataFim = generatorService.ultimoDiaDoProximoMes()
            let sessoesGeradas = generatorService.gerarSessoes(para: novaRegra, dataFim: dataFim)
            
            // 3. Persiste a geração em lote
            for sessao in sessoesGeradas {
                sessionRepository.salvarSessao(sessao)
            }
            
            print("✅ Regra criada e \(sessoesGeradas.count) sessões geradas até o fim do mês que vem!")
            
        } else {
            
            // Cria um evento único sem projeção futura
            let sessaoUnica = Session(
                id: "sess_\(UUID().uuidString)",
                psicologoID: paciente.psicologoID,
                pacienteID: paciente.id,
                sessaoFixaID: nil,
                dataDaSessão: selectedDate,
                status: .agendada,
                modalidade: selectedModalidade,
                horaInicio: horaFormatada
            )
            
            sessionRepository.salvarSessao(sessaoUnica)
            
            print("✅ Sessão avulsa criada para o dia: \(sessaoUnica.dataDaSessão)")
        }
    }
}
