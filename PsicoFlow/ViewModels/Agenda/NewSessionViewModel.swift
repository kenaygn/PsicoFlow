//
//  NewSessionViewModel.swift
//  PsicoFlow
//
//  Created by Kenay on 13/04/26.
//

import Foundation
import Combine

class NewSessionViewModel: ObservableObject {
    
    // MARK: - Dependências e Serviços
    private let patientRepository: PatientRepositoryProtocol
    private let sessionRepository: SessionRepositoryProtocol
    private let fixedSessionRepository: FixedSessionRepositoryProtocol
    private let generatorService = SessionGeneratorService()
    
    private let todosHorarios: [String] = [
        "07:00", "08:00", "09:00", "10:00", "11:00", "12:00",
        "13:00", "14:00", "15:00", "16:00", "17:00", "18:00", "19:00", "20:00", "21:00", "22:00"
    ]
    
    // MARK: - Estados da Tela (@Published)
    @Published var pacientesDisponiveis: [Patient] = []
    @Published var pacienteSelecionadoID: String = ""
    @Published var isFixedSession: Bool = false
    @Published var selectedDate: Date = Date()
    @Published var selectedWeekday: Int = Calendar.current.component(.weekday, from: Date())
    @Published var selectedTime: String = "08:00"
    @Published var selectedModalidade: Modalidade = .presencial
    
    // MARK: - Propriedades Computadas
    var horaFormatada: String {
        return selectedTime
    }
    
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
    
    // MARK: - Inicialização (Injeção de Dependência)
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
        
        // Aplica sugestões da tela anterior
        self.selectedDate = dataSugerida
        self.selectedTime = horarioSugerido
        self.selectedWeekday = Calendar.current.component(.weekday, from: dataSugerida)
        
        carregarPacientes()
    }
    
    // MARK: - Lógica de Negócio e Ações
    
    private func carregarPacientes() {
        self.pacientesDisponiveis = patientRepository.fetchPacientes().filter { $0.status == .ativo }
        if let primeiro = pacientesDisponiveis.first {
            self.pacienteSelecionadoID = primeiro.id
        }
    }
    
    // Trava de Segurança: Ajusta o Picker se o horário ficar ocupado ao trocar de dia
    func atualizarSelecaoDeHorario() {
        if !horariosLivres.contains(selectedTime) {
            selectedTime = horariosLivres.first ?? ""
        }
    }
    
    func salvarSessao() {
        guard let paciente = pacientesDisponiveis.first(where: { $0.id == pacienteSelecionadoID }) else { return }
        
        if isFixedSession {
            // 1. Cria a regra
            let novaRegra = FixedSession(
                id: "fix_\(UUID().uuidString)",
                psicologoID: paciente.psicologoID,
                pacienteID: paciente.id,
                diaDaSemana: selectedWeekday,
                horaInicio: horaFormatada,
                modalidade: selectedModalidade
            )
            
            fixedSessionRepository.salvarSessaoFixa(novaRegra)
            
            // 2. Chama o gerador para criar as filhas
            let dataFim = generatorService.ultimoDiaDoProximoMes()
            let sessoesGeradas = generatorService.gerarSessoes(para: novaRegra, dataFim: dataFim)
            
            // 3. Salva no banco
            for sessao in sessoesGeradas {
                sessionRepository.salvarSessao(sessao)
            }
            
            print("✅ Regra criada e \(sessoesGeradas.count) sessões geradas até o fim do mês que vem!")
            
        } else {
            // Cria apenas um evento único
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
