//
//  AgendaViewModel.swift
//  PsicoFlow
//
//  Created by Kenay on 08/04/26.
//

import Foundation
import Combine

/// ViewModel responsável pelo controle de estado e navegação temporal da tela de Agenda.
/// Gerencia a projeção de dias da semana, a montagem da linha do tempo (timeline)
/// e o cruzamento de sessões com os horários de expediente.
class AgendaViewModel: ObservableObject {
    
    @Published var selectedDate: Date = Date()
    @Published var weekDays: [Date] = []
    
    /// Data âncora utilizada para calcular o intervalo da semana atualmente visível na tela.
    @Published private var dataBaseDaSemana: Date = Date()
    
    @Published private var todasSessoes: [Session] = []
    @Published private var pacientes: [Patient] = []
    
    var timeSlots: [String] {
        availabilityService.todosHorarios
    }
    
    private let sessionRepository: SessionRepositoryProtocol
    private let patientRepository: PatientRepositoryProtocol
    private let fixedSessionRepository: FixedSessionRepositoryProtocol
    
    private let availabilityService: AgendaAvailabilityService
    
    init(
        sessionRepository: SessionRepositoryProtocol = MockSessionRepository(),
        patientRepository: PatientRepositoryProtocol = MockPatientRepository(),
        fixedSessionRepository: FixedSessionRepositoryProtocol = MockFixedSessionRepository()
    ) {
        self.sessionRepository = sessionRepository
        self.patientRepository = patientRepository
        self.fixedSessionRepository = fixedSessionRepository
        
        self.availabilityService = AgendaAvailabilityService(
            fixedSessionRepository: fixedSessionRepository,
            sessionRepository: sessionRepository
        )
        
        
        gerarDiasDaSemana()
        carregarDados()
    }
    
    func carregarDados() {
        self.todasSessoes = sessionRepository.fetchSessoes()
        self.pacientes = patientRepository.fetchPacientes()
    }
    
    func avancarSemana() {
        if let proxima = Calendar.current.date(byAdding: .weekOfYear, value: 1, to: dataBaseDaSemana) {
            dataBaseDaSemana = proxima
            gerarDiasDaSemana()
        }
    }
    
    func voltarSemana() {
        if let anterior = Calendar.current.date(byAdding: .weekOfYear, value: -1, to: dataBaseDaSemana) {
            dataBaseDaSemana = anterior
            gerarDiasDaSemana()
        }
    }
    
    var mesAnoAtual: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "pt_BR")
        formatter.dateFormat = "MMMM yyyy"
        return formatter.string(from: selectedDate).capitalized
    }
    
    /// Calcula e projeta os 7 dias da semana com base na `dataBaseDaSemana` atual.
    private func gerarDiasDaSemana() {
        let calendar = Calendar.current
        
        // Encontra o domingo correspondente à semana base
        guard let inicioDaSemana = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: dataBaseDaSemana)) else { return }
        
        var dias: [Date] = []
        for i in 0..<7 {
            if let dia = calendar.date(byAdding: .day, value: i, to: inicioDaSemana) {
                dias.append(dia)
            }
        }
        self.weekDays = dias
        
        // Regra de Seleção Automática:
        // - Se a semana visível contiver o dia de hoje, foca no hoje.
        // - Se for uma semana no passado/futuro, foca na segunda-feira (índice 1).
        if dias.contains(where: { calendar.isDate($0, inSameDayAs: Date()) }) {
            self.selectedDate = Date()
        } else {
            self.selectedDate = dias[1]
        }
    }
    
    func selecionarData(_ data: Date) {
        self.selectedDate = data
    }
    
    func irParaHoje() {
        dataBaseDaSemana = Date()
        gerarDiasDaSemana()
    }
    
    func pularParaData(_ data: Date) {
        dataBaseDaSemana = data
        gerarDiasDaSemana()
        selecionarData(data)
    }
    
    var isHojeSelecionado: Bool {
        return Calendar.current.isDateInToday(selectedDate)
    }
    
    func isHoje(_ data: Date) -> Bool {
        return Calendar.current.isDateInToday(data)
    }
    
    func isMesmoDia(_ data1: Date, _ data2: Date) -> Bool {
        return Calendar.current.isDate(data1, inSameDayAs: data2)
    }
    
    func nomeCurtoDoDia(_ data: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "pt_BR")
        formatter.dateFormat = "EEE"
        return formatter.string(from: data).capitalized
    }
    
    func numeroDoDia(_ data: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd"
        return formatter.string(from: data)
    }
    
    /// Retorna as sessões mapeadas para um slot de tempo específico no dia atualmente selecionado.
    func sessoesPara(horario: String) -> [Session] {
        return todasSessoes.filter { sessao in
            isMesmoDia(sessao.dataDaSessão, selectedDate) &&
            sessao.horaInicio == horario &&
            sessao.status != .cancelada // Exclui sessões canceladas da linha do tempo visual
        }
    }
    
    func pacientePara(sessao: Session) -> Patient? {
        return pacientes.first { $0.id == sessao.pacienteID }
    }
    
    /// Processa a mutação de estado de uma sessão a partir do atalho da UI.
    func atualizarStatus(da sessao: Session, para novoStatus: SessionStatus, novaData: Date? = nil) {
        var sessaoAtualizada = sessao
        sessaoAtualizada.status = novoStatus
        
        // Tratamento especial para reagendamentos
        if novoStatus == .adiada, let data = novaData {
            sessaoAtualizada.dataDaSessão = data
            sessaoAtualizada.sessaoFixaID = nil // Desvincula o evento avulso do contrato matriz
            
            let formatter = DateFormatter()
            formatter.dateFormat = "HH:mm"
            sessaoAtualizada.horaInicio = formatter.string(from: data)
        }
        
        sessionRepository.atualizarSessao(sessaoAtualizada)
        carregarDados()
    }
    
    /// Procura em toda a base de dados a data do primeiro conflito existente na agenda
    var primeiraDataComConflito: Date? {
        let sessoesAtivas = todasSessoes.filter { $0.status != .cancelada }
        
        // Vamos agrupar as sessões por "Data + Hora". Ex: "2026-05-24-14:00"
        var agrupamento: [String: [Session]] = [:]
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        
        for sessao in sessoesAtivas {
            let chaveDeTempo = formatter.string(from: sessao.dataDaSessão) + "-" + sessao.horaInicio
            agrupamento[chaveDeTempo, default: []].append(sessao)
        }
        
        // Filtra os grupos que têm mais de 1 sessão no mesmo slot
        let gruposComConflito = agrupamento.values.filter { $0.count > 1 }
        
        // Pega a data exata da primeira sessão de cada grupo conflitante
        let datasComConflito = gruposComConflito.compactMap { $0.first?.dataDaSessão }
        
        // Retorna a data mais próxima de hoje (ou a primeira da lista)
        return datasComConflito.sorted().first
    }
}
