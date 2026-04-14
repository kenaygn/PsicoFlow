//
//  AgendaViewModel.swift
//  PsicoFlow
//
//  Created by Kenay on 08/04/26.
//

import Foundation
import Combine

class AgendaViewModel: ObservableObject {
    // Estado da Tela
    @Published var selectedDate: Date = Date()
    @Published var weekDays: [Date] = []
    
    @Published private var dataBaseDaSemana: Date = Date()
    
    // Dados Brutos
    @Published private var todasSessoes: [Session] = []
    @Published private var pacientes: [Patient] = []
    
    // Horários fixos da clínica (07:00 às 22:00)
    let timeSlots: [String] = [
        "07:00", "08:00", "09:00", "10:00", "11:00", "12:00",
        "13:00", "14:00", "15:00", "16:00", "17:00", "18:00", "19:00", "20:00", "21:00", "22:00"
    ]
    
    // Repositórios
    private let sessionRepository: SessionRepositoryProtocol
    private let patientRepository: PatientRepositoryProtocol
    
    init(
        sessionRepository: SessionRepositoryProtocol = MockSessionRepository(),
        patientRepository: PatientRepositoryProtocol = MockPatientRepository()
    ) {
        self.sessionRepository = sessionRepository
        self.patientRepository = patientRepository
        
        gerarDiasDaSemana()
        carregarDados()
    }
    
    func carregarDados() {
        self.todasSessoes = sessionRepository.fetchSessoes()
        self.pacientes = patientRepository.fetchPacientes()
    }
    
    // MARK: - Lógica de Navegação de Semanas
    
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
    
    // MARK: - Lógica de Calendário
    
    // Gera os 7 dias baseados na "dataBaseDaSemana" em vez de ser fixo no hoje
    private func gerarDiasDaSemana() {
        let calendar = Calendar.current
        
        // Encontra o domingo da semana base
        guard let inicioDaSemana = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: dataBaseDaSemana)) else { return }
        
        var dias: [Date] = []
        for i in 0..<7 {
            if let dia = calendar.date(byAdding: .day, value: i, to: inicioDaSemana) {
                dias.append(dia)
            }
        }
        self.weekDays = dias
        
        // Se a semana gerada for a semana atual, seleciona o dia de hoje.
        // Se for uma semana do futuro/passado, seleciona a segunda-feira (índice 1).
        if dias.contains(where: { calendar.isDate($0, inSameDayAs: Date()) }) {
            self.selectedDate = Date()
        } else {
            self.selectedDate = dias[1] // Segunda-feira
        }
    }
    
    func selecionarData(_ data: Date) {
        self.selectedDate = data
    }
    
    // MARK: - Formatadores para a View
    
    func nomeCurtoDoDia(_ data: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "pt_BR")
        formatter.dateFormat = "EEE" // Ex: "Dom", "Seg"
        return formatter.string(from: data).capitalized
    }
    
    func numeroDoDia(_ data: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd" // Ex: "29", "30"
        return formatter.string(from: data)
    }
    
    func isMesmoDia(_ data1: Date, _ data2: Date) -> Bool {
        return Calendar.current.isDate(data1, inSameDayAs: data2)
    }
    
    // MARK: - Lógica de Timeline
    
    func sessaoPara(horario: String) -> Session? {
        return todasSessoes.first { sessao in
            isMesmoDia(sessao.dataDaSessão, selectedDate) && sessao.horaInicio == horario && sessao.status != .cancelada
        }
    }
    
    func pacientePara(sessao: Session) -> Patient? {
        return pacientes.first { $0.id == sessao.pacienteID }
    }
    
    // Pula direto para a data de Hoje
    func irParaHoje() {
        dataBaseDaSemana = Date()
        gerarDiasDaSemana()
    }
    
    // Pula para qualquer data selecionada no calendário
    func pularParaData(_ data: Date) {
        dataBaseDaSemana = data
        gerarDiasDaSemana()
        selecionarData(data)
    }
    
    // Verifica se o dia selecionado na tela é o dia de hoje
    var isHojeSelecionado: Bool {
        return Calendar.current.isDateInToday(selectedDate)
    }
    
    // Verifica se uma data específica da fileira é o dia de hoje
    func isHoje(_ data: Date) -> Bool {
        return Calendar.current.isDateInToday(data)
    }
    
    // MARK: - Ações Rápidas da Sessão
    func atualizarStatus(da sessao: Session, para novoStatus: SessionStatus, novaData: Date? = nil) {
        var sessaoAtualizada = sessao
        sessaoAtualizada.status = novoStatus
        
        // Se foi adiada e recebemos uma data nova, atualizamos os valores!
        if novoStatus == .adiada, let data = novaData {
            sessaoAtualizada.dataDaSessão = data
            
            // Extrai a hora exata da nova data para a string "HH:mm"
            let formatter = DateFormatter()
            formatter.dateFormat = "HH:mm"
            sessaoAtualizada.horaInicio = formatter.string(from: data)
        }
        
        sessionRepository.atualizarSessao(sessaoAtualizada)
        carregarDados()
    }
}
