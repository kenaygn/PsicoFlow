//
//  AgendaViewModel.swift
//  PsicoFlow
//
//  Created by Kenay on 08/04/26.
//

import Foundation
import Combine
import SwiftUI
import FirebaseFirestore

class AgendaViewModel: ObservableObject {
    
    @Published var selectedDate: Date = Date()
    @Published var weekDays: [Date] = []
    @Published private var dataBaseDaSemana: Date = Date()
    
    @Published private var todasSessoes: [Session] = []
    @Published private var pacientes: [Patient] = []
    
    // Listeners para o padrão Offline-First
    private var sessoesListener: ListenerRegistration?
    private var pacientesListener: ListenerRegistration?
    
    var timeSlots: [String] {
        availabilityService.todosHorarios
    }
    
    private let sessionRepository: SessionRepositoryProtocol
    private let patientRepository: PatientRepositoryProtocol
    private let fixedSessionRepository: FixedSessionRepositoryProtocol
    private let availabilityService: AgendaAvailabilityService
    
    init(
        sessionRepository: SessionRepositoryProtocol = SessionFirebaseRepository(),
        patientRepository: PatientRepositoryProtocol = PatientFirebaseRepository(),
        fixedSessionRepository: FixedSessionRepositoryProtocol = FixedSessionFirebaseRepository()
    ) {
        self.sessionRepository = sessionRepository
        self.patientRepository = patientRepository
        self.fixedSessionRepository = fixedSessionRepository
        
        self.availabilityService = AgendaAvailabilityService(
            fixedSessionRepository: fixedSessionRepository,
            sessionRepository: sessionRepository
        )
        
        gerarDiasDaSemana()
    }
    
    deinit {
        sessoesListener?.remove()
        pacientesListener?.remove()
    }
    
    // MARK: - Carregamento Offline-First (Tempo Real)
    
    func carregarDados(userId: String) {
        guard !userId.isEmpty else { return }
        
        sessoesListener?.remove()
        pacientesListener?.remove()
        
        // 1. Ouvinte em tempo real para sessões
        if let sessionRepo = sessionRepository as? SessionFirebaseRepository {
            sessoesListener = sessionRepo.escutarSessoes(userId: userId) { [weak self] novasSessoes in
                guard let self = self else { return }
                withAnimation(.easeInOut(duration: 0.3)) {
                    self.todasSessoes = novasSessoes
                }
            }
        }
        
        // 2. Ouvinte em tempo real para pacientes
        if let patientRepo = patientRepository as? PatientFirebaseRepository {
            pacientesListener = patientRepo.escutarPacientes(userId: userId) { [weak self] novosPacientes in
                guard let self = self else { return }
                withAnimation(.easeInOut(duration: 0.3)) {
                    self.pacientes = novosPacientes
                }
            }
        }
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
    
    private func gerarDiasDaSemana() {
        let calendar = Calendar.current
        guard let inicioDaSemana = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: dataBaseDaSemana)) else { return }
        
        var dias: [Date] = []
        for i in 0..<7 {
            if let dia = calendar.date(byAdding: .day, value: i, to: inicioDaSemana) {
                dias.append(dia)
            }
        }
        self.weekDays = dias
        
        if dias.contains(where: { calendar.isDate($0, inSameDayAs: Date()) }) {
            self.selectedDate = Date()
        } else {
            self.selectedDate = dias[1]
        }
    }
    
    func selecionarData(_ data: Date) { self.selectedDate = data }
    func irParaHoje() { dataBaseDaSemana = Date(); gerarDiasDaSemana() }
    
    func pularParaData(_ data: Date) {
        dataBaseDaSemana = data
        gerarDiasDaSemana()
        selecionarData(data)
    }
    
    var isHojeSelecionado: Bool { Calendar.current.isDateInToday(selectedDate) }
    func isHoje(_ data: Date) -> Bool { Calendar.current.isDateInToday(data) }
    func isMesmoDia(_ data1: Date, _ data2: Date) -> Bool { Calendar.current.isDate(data1, inSameDayAs: data2) }
    
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
    
    func sessoesPara(horario: String) -> [Session] {
        return todasSessoes.filter { sessao in
            isMesmoDia(sessao.dataDaSessao, selectedDate) &&
            sessao.horaInicio == horario &&
            sessao.status != .cancelada
        }
    }
    
    func pacientePara(sessao: Session) -> Patient? {
        return pacientes.first { $0.id == sessao.pacienteID }
    }
    
    // MARK: - Atualização com Atualização Otimista
    
    func atualizarStatus(da sessao: Session, para novoStatus: SessionStatus, novaData: Date? = nil, userId: String) {
        var sessaoAtualizada = sessao
        sessaoAtualizada.status = novoStatus
        
        if novoStatus == .adiada, let data = novaData {
            sessaoAtualizada.dataDaSessao = data
            sessaoAtualizada.sessaoFixaID = nil
            
            let formatter = DateFormatter()
            formatter.dateFormat = "HH:mm"
            sessaoAtualizada.horaInicio = formatter.string(from: data)
        }
        
        // Atualização otimista imediata na UI local
        if let index = todasSessoes.firstIndex(where: { $0.id == sessao.id }) {
            withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                todasSessoes[index] = sessaoAtualizada
            }
        }
        
        // Persistência em background
        Task {
            do {
                try await sessionRepository.atualizarSessao(sessaoAtualizada, userId: userId)
            } catch {
                print("Erro ao atualizar status na agenda: \(error.localizedDescription)")
            }
        }
    }
    
    var primeiraDataComConflito: Date? {
        let sessoesAtivas = todasSessoes.filter { $0.status != .cancelada }
        var agrupamento: [String: [Session]] = [:]
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        
        for sessao in sessoesAtivas {
            let chaveDeTempo = formatter.string(from: sessao.dataDaSessao) + "-" + sessao.horaInicio
            agrupamento[chaveDeTempo, default: []].append(sessao)
        }
        
        let gruposComConflito = agrupamento.values.filter { $0.count > 1 }
        return gruposComConflito.compactMap { $0.first?.dataDaSessao }.sorted().first
    }
}
