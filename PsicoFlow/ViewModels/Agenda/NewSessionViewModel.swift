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
    private let generatorService = SessionGeneratorService()
    
    // Note: Conforme padronizado nas outras ViewModels, idealmente esta matriz
    // deve vir de uma configuração global do usuário/clínica.
    private let todosHorarios: [String] = [
        "07:00", "08:00", "09:00", "10:00", "11:00", "12:00",
        "13:00", "14:00", "15:00", "16:00", "17:00", "18:00", "19:00", "20:00", "21:00", "22:00"
    ]
        
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
        
        carregarPacientes()
    }
        
    var horaFormatada: String {
        return selectedTime
    }
    
    /// Calcula os horários disponíveis aplicando regras de exclusão dinâmicas:
    /// - Se for sessão fixa: Compara com outras regras fixas ativas no mesmo dia da semana.
    /// - Se for avulsa: Compara com as sessões ativas (não canceladas) no dia exato.
    var horariosLivres: [String] {
        if isFixedSession {
            let regrasNoMesmoDia = fixedSessionRepository.fetchSessoesFixas().filter { $0.diaDaSemana == selectedWeekday }
            let ocupados = regrasNoMesmoDia.map { $0.horaInicio }
            return todosHorarios.filter { !ocupados.contains($0) }
            
        } else {
            let sessoesNoMesmoDia = sessionRepository.fetchSessoes().filter {
                Calendar.current.isDate($0.dataDaSessão, inSameDayAs: selectedDate) &&
                $0.status != .cancelada
            }
            let ocupados = sessoesNoMesmoDia.map { $0.horaInicio }
            return todosHorarios.filter { !ocupados.contains($0) }
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
