//
//  HomeViewModel.swift
//  PsicoFlow
//
//  Created by Kenay on 02/04/26.
//

import SwiftUI
import Foundation
import Combine
import FirebaseFirestore

class HomeViewModel: ObservableObject {
    
    enum HomeSlide: Hashable {
        case conflito, proximaSessao, resumo, pendencias, premium
    }
    
    @Published var sessoesHoje: [Session] = []
    @Published var pacientes: [Patient] = []
    @Published var valoresPendentes: Double = 0.0
    @Published var isUsuarioPremium: Bool = false
    
    @Published var mensagemConflito: String = ""
    @Published var mostrarAlertaConflito: Bool = false
    
    @Published var carregamentoInicialConcluido: Bool = false
    
    private var todasSessoes: [Session] = []
    private var todosPagamentos: [MonthlyPayment] = []
    
    private var sessoesListener: ListenerRegistration?
    private var pacientesListener: ListenerRegistration?
    private var pagamentosListener: ListenerRegistration?
    private var userListener: ListenerRegistration?
    
    private var financeAnalyzer = FinanceAnalyzerService()
    
    private let patientRepository: PatientRepositoryProtocol
    private let sessionRepository: SessionRepositoryProtocol
    private let paymentRepository: PaymentRepositoryProtocol
    private let userRepository: UserRepositoryProtocol
    
    init(
        patientRepository: PatientRepositoryProtocol = PatientFirebaseRepository(),
        sessionRepository: SessionRepositoryProtocol = SessionFirebaseRepository(),
        paymentRepository: PaymentRepositoryProtocol = PaymentFirebaseRepository(),
        userRepository: UserRepositoryProtocol = UserFirebaseRepository()
    ) {
        self.patientRepository = patientRepository
        self.sessionRepository = sessionRepository
        self.paymentRepository = paymentRepository
        self.userRepository = userRepository
    }
    
    deinit {
        sessoesListener?.remove()
        pacientesListener?.remove()
        pagamentosListener?.remove()
        userListener?.remove()
    }
    
    
    func carregarDados(userId: String) {
        guard !userId.isEmpty else { return }
        
        sessoesListener?.remove()
        pacientesListener?.remove()
        pagamentosListener?.remove()
        userListener?.remove()
        
        if let sessionRepo = sessionRepository as? SessionFirebaseRepository {
            sessoesListener = sessionRepo.listenToSessions(userId: userId) { [weak self] novasSessoes in
                guard let self = self else { return }
                withAnimation(.easeInOut(duration: 0.4)) {
                    self.todasSessoes = novasSessoes
                    self.processarDadosLocais(userId: userId)
                }
            }
        }
        
        if let patientRepo = patientRepository as? PatientFirebaseRepository {
            pacientesListener = patientRepo.listenToPatients(userId: userId) { [weak self] novosPacientes in
                guard let self = self else { return }
                withAnimation(.easeInOut(duration: 0.4)) {
                    self.pacientes = novosPacientes
                    self.processarDadosLocais(userId: userId)
                }
            }
        }
        
        if let paymentRepo = paymentRepository as? PaymentFirebaseRepository {
            pagamentosListener = paymentRepo.listenToPayments(userId: userId) { [weak self] novosPagamentos in
                guard let self = self else { return }
                withAnimation(.easeInOut(duration: 0.4)) {
                    self.todosPagamentos = novosPagamentos
                    self.processarDadosLocais(userId: userId)
                    
                    self.carregamentoInicialConcluido = true
                }
            }
        }
        
        if let userRepo = userRepository as? UserFirebaseRepository {
            userListener = userRepo.listenToUsers(uid: userId) { [weak self] usuarioAtualizado in
                guard let self = self else { return }
                withAnimation(.easeInOut(duration: 0.4)) {
                    self.isUsuarioPremium = usuarioAtualizado?.premium ?? false
                }
            }
        }
    }
    
    var limitePlanoFreeAtingido: Bool {
        if isUsuarioPremium { return false }
        return pacientes.count >= 5
    }
    
    private func processarDadosLocais(userId: String) {
        var sessoesDeHoje = todasSessoes
            .filter { Calendar.current.isDateInToday($0.sessionDate) }
            .sorted { $0.startTime < $1.startTime }
        
        for i in 0..<sessoesDeHoje.count {
            if sessoesDeHoje[i].status == .postponed {
                sessoesDeHoje[i].status = .scheduled
                let sessaoParaAtualizar = sessoesDeHoje[i]
                Task { try? await sessionRepository.updateSession(sessaoParaAtualizar, userId: userId) }
            }
        }
        self.sessoesHoje = sessoesDeHoje
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy/MM"
        let mesAtualStr = formatter.string(from: Date())
        
        self.valoresPendentes = todosPagamentos
            .filter { !$0.paid && $0.referenceMonth <= mesAtualStr }
            .reduce(0) { $0 + $1.value }
    }
    
    
    func atualizarStatusDaSessao(sessaoID: String, novoStatus: SessionStatus, novaData: Date? = nil, userId: String) {
        if let index = sessoesHoje.firstIndex(where: { $0.id == sessaoID }) {
            
            Task {
                if let novaData = novaData, novoStatus == .postponed {
                    if let conflito = try? await verificarConflito(novaData: novaData, ignorandoSessaoID: sessaoID, userId: userId) {
                        await MainActor.run {
                            self.mensagemConflito = "Este horário conflita com a sessão de \(conflito.nome) às \(conflito.hora)."
                            self.mostrarAlertaConflito = true
                        }
                        return
                    }
                }
                
                var sessaoAtualizada = sessoesHoje[index]
                sessaoAtualizada.status = novoStatus
                
                if let novaData = novaData, novoStatus == .postponed {
                    sessaoAtualizada.sessionDate = novaData
                    sessaoAtualizada.fixedSessionID = nil
                    
                    let formatter = DateFormatter()
                    formatter.dateFormat = "HH:mm"
                    sessaoAtualizada.startTime = formatter.string(from: novaData)
                    
                    if Calendar.current.isDateInToday(novaData) {
                        sessaoAtualizada.status = .scheduled
                    }
                }
                
                await MainActor.run {
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                        self.sessoesHoje[index] = sessaoAtualizada
                        if let idxTodas = self.todasSessoes.firstIndex(where: { $0.id == sessaoID }) {
                            self.todasSessoes[idxTodas] = sessaoAtualizada
                        }
                        self.processarDadosLocais(userId: userId)
                    }
                }
                
                try? await sessionRepository.updateSession(sessaoAtualizada, userId: userId)
            }
        }
    }
    
    private func verificarConflito(novaData: Date, ignorandoSessaoID: String, userId: String) async throws -> (nome: String, hora: String)? {
        let calendar = Calendar.current
        let formatador = DateFormatter()
        formatador.dateFormat = "HH:mm"
        
        let novaHoraStr = formatador.string(from: novaData)
        let minutosNovaSessao = converterParaMinutos(novaHoraStr)
        
        let sessoesParaValidar = todasSessoes
        
        for sessao in sessoesParaValidar {
            if sessao.id == ignorandoSessaoID || sessao.status == .cancelled { continue }
            
            if calendar.isDate(sessao.sessionDate, inSameDayAs: novaData) {
                let minutosSessaoExistente = converterParaMinutos(sessao.startTime)
                
                if abs(minutosNovaSessao - minutosSessaoExistente) < 60 {
                    if let pacienteConflito = pacientes.first(where: { $0.id == sessao.patientID }) {
                        return (nome: pacienteConflito.name, hora: sessao.startTime)
                    }
                }
            }
        }
        return nil
    }
    
    private func converterParaMinutos(_ hora: String) -> Int {
        let partes = hora.split(separator: ":")
        if partes.count == 2, let h = Int(partes[0]), let m = Int(partes[1]) {
            return (h * 60) + m
        }
        return 0
    }
    
    func obterHorariosLivres(para data: Date, ignorandoSessaoID sessaoID: String, userId: String) async -> [String] {
        let sessaoAtual = todasSessoes.first { $0.id == sessaoID }
        
        let service = AgendaAvailabilityService(
            fixedSessionRepository: FixedSessionFirebaseRepository(),
            sessionRepository: SessionFirebaseRepository()
        )
        
        do {
            return try await service.freeSlotsForSingleSession(
                date: data,
                ignoringSessionID: sessaoID,
                derivedFromContractID: sessaoAtual?.fixedSessionID,
                userId: userId
            )
        } catch {
            print("Erro ao buscar horários livres: \(error.localizedDescription)")
            return []
        }
    }
        
    var primeiraDataComConflito: Date? {
        let sessoesAtivas = todasSessoes.filter { $0.status != .cancelled }
        var agrupamento: [String: [Session]] = [:]
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        
        for sessao in sessoesAtivas {
            let chaveDeTempo = formatter.string(from: sessao.sessionDate) + "-" + sessao.startTime
            agrupamento[chaveDeTempo, default: []].append(sessao)
        }
        
        return agrupamento.values.filter { $0.count > 1 }.compactMap { $0.first?.sessionDate }.sorted().first
    }
    
    var slidesAtivos: [HomeSlide] {
        var slides: [HomeSlide] = []
        if proximaSessao != nil { slides.append(.proximaSessao) } else { slides.append(.resumo) }
        if primeiraDataComConflito != nil { slides.append(.conflito) }
        if primeiraPendenciaAtrasada != nil { slides.append(.pendencias) }
        if !isUsuarioPremium { slides.append(.premium) }
        return slides
    }
    
    var proximaSessao: Session? {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        let horaAtual = formatter.string(from: Date())
        
        return sessoesHoje.first { sessao in
            sessao.startTime >= horaAtual && sessao.status == .scheduled
        }
    }
    
    var nomePacienteProximaSessao: String {
        guard let proxima = proximaSessao,
              let paciente = pacientes.first(where: { $0.id == proxima.patientID }) else {
            return "Paciente não encontrado"
        }
        return paciente.name
    }
    
    var totalSessoesHojeText: String {
        return "\(sessoesHoje.count)"
    }
    
    var valoresPendentesText: String {
        return String(format: "R$ %.0f", valoresPendentes)
    }
    
    func paciente(for session: Session) -> Patient? {
        return pacientes.first(where: { $0.id == session.patientID })
    }
    
    func verificarSeEProximaSessao(_ sessao: Session) -> Bool {
        guard let proxima = proximaSessao else { return false }
        return sessao.id == proxima.id
    }
    
    var atendimentosRealizadosNaSemana: Int {
        let calendar = Calendar.current
        let hoje = Date()
        
        guard let inicioDaSemana = calendar.dateInterval(of: .weekOfYear, for: hoje)?.start else {
            return 0
        }
        
        let realizadasPassadas = todasSessoes.filter { sessao in
            let naoEHoje = !calendar.isDateInToday(sessao.sessionDate)
            let dentroDaSemana = sessao.sessionDate >= inicioDaSemana
            return sessao.status == .completed && dentroDaSemana && naoEHoje
        }.count
        
        let realizadasHoje = sessoesHoje.filter { $0.status == .completed }.count
        
        return realizadasPassadas + realizadasHoje
    }
    
    var primeiraPendenciaAtrasada: Date? {
        return financeAnalyzer.identificarPrimeiroMesComAtraso(nos: todosPagamentos)
    }
    
    var labelPendenciaFinanceira: String {
        guard let data = primeiraPendenciaAtrasada else { return "" }
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "pt_BR")
        formatter.dateFormat = "MMMM/yyyy"
        return formatter.string(from: data).capitalized
    }
}
