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
    
    // Dados Brutos
    @Published private var todasSessoes: [Session] = []
    @Published private var pacientes: [Patient] = []
    
    // Horários fixos da clínica (08:00 às 22:00)
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
    
    // MARK: - Lógica de Calendário
    
    // Gera os 7 dias da semana atual (Domingo a Sábado)
    private func gerarDiasDaSemana() {
        let calendar = Calendar.current
        let hoje = Date()
        
        // Encontra o domingo desta semana
        guard let inicioDaSemana = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: hoje)) else { return }
        
        var dias: [Date] = []
        for i in 0..<7 {
            if let dia = calendar.date(byAdding: .day, value: i, to: inicioDaSemana) {
                dias.append(dia)
            }
        }
        self.weekDays = dias
        
        // Se o dia atual estiver nessa semana, seleciona ele por padrão
        if dias.contains(where: { calendar.isDate($0, inSameDayAs: hoje) }) {
            self.selectedDate = hoje
        } else {
            self.selectedDate = inicioDaSemana
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
    
    // A View vai passar "14:00" e essa função retorna a sessão se existir
    func sessaoPara(horario: String) -> Session? {
        return todasSessoes.first { sessao in
            isMesmoDia(sessao.dataDaSessão, selectedDate) && sessao.horaInicio == horario && sessao.status != .cancelada
        }
    }
    
    func pacientePara(sessao: Session) -> Patient? {
        return pacientes.first { $0.id == sessao.pacienteID }
    }
}
