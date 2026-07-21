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
        case conflito, proximaSessao, resumo, pendencias
    }
    
    @Published var sessoesHoje: [Session] = []
    @Published var pacientes: [Patient] = []
    @Published var valoresPendentes: Double = 0.0
    
    @Published var mensagemConflito: String = ""
    @Published var mostrarAlertaConflito: Bool = false
    
    private var todasSessoes: [Session] = []
    private var todosPagamentos: [MonthlyPayment] = []
    
    // Listeners para manter a sincronia offline-first em tempo real
    private var sessoesListener: ListenerRegistration?
    private var pacientesListener: ListenerRegistration?
    private var pagamentosListener: ListenerRegistration?
    
    private var financeAnalyzer = FinanceAnalyzerService()
    
    private let patientRepository: PatientRepositoryProtocol
    private let sessionRepository: SessionRepositoryProtocol
    private let paymentRepository: PaymentRepositoryProtocol
    
    init(
        patientRepository: PatientRepositoryProtocol = PatientFirebaseRepository(),
        sessionRepository: SessionRepositoryProtocol = SessionFirebaseRepository(),
        paymentRepository: PaymentRepositoryProtocol = PaymentFirebaseRepository()
    ) {
        self.patientRepository = patientRepository
        self.sessionRepository = sessionRepository
        self.paymentRepository = paymentRepository
    }
    
    deinit {
        sessoesListener?.remove()
        pacientesListener?.remove()
        pagamentosListener?.remove()
    }
    
    // MARK: - Carregamento Offline-First (Tempo Real)
    
    func carregarDados(userId: String) {
        guard !userId.isEmpty else { return }
        
        // Remove ouvintes anteriores para evitar vazamento ou duplicação
        sessoesListener?.remove()
        pacientesListener?.remove()
        pagamentosListener?.remove()
        
        // 1. Escuta Sessões
        if let sessionRepo = sessionRepository as? SessionFirebaseRepository {
            sessoesListener = sessionRepo.escutarSessoes(userId: userId) { [weak self] novasSessoes in
                guard let self = self else { return }
                withAnimation(.easeInOut(duration: 0.4)) {
                    self.todasSessoes = novasSessoes
                    self.processarDadosLocais(userId: userId)
                }
            }
        }
        
        // 2. Escuta Pacientes
        if let patientRepo = patientRepository as? PatientFirebaseRepository {
            pacientesListener = patientRepo.escutarPacientes(userId: userId) { [weak self] novosPacientes in
                guard let self = self else { return }
                withAnimation(.easeInOut(duration: 0.4)) {
                    self.pacientes = novosPacientes
                    self.processarDadosLocais(userId: userId)
                }
            }
        }
        
        // 3. Escuta Pagamentos
        if let paymentRepo = paymentRepository as? PaymentFirebaseRepository {
            pagamentosListener = paymentRepo.escutarPagamentos(userId: userId) { [weak self] novosPagamentos in
                guard let self = self else { return }
                withAnimation(.easeInOut(duration: 0.4)) {
                    self.todosPagamentos = novosPagamentos
                    self.processarDadosLocais(userId: userId)
                }
            }
        }
    }
    
    private func processarDadosLocais(userId: String) {
        var sessoesDeHoje = todasSessoes
            .filter { Calendar.current.isDateInToday($0.dataDaSessão) }
            .sorted { $0.horaInicio < $1.horaInicio }
        
        for i in 0..<sessoesDeHoje.count {
            if sessoesDeHoje[i].status == .adiada {
                sessoesDeHoje[i].status = .agendada
                let sessaoParaAtualizar = sessoesDeHoje[i]
                Task { try? await sessionRepository.atualizarSessao(sessaoParaAtualizar, userId: userId) }
            }
        }
        self.sessoesHoje = sessoesDeHoje
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy/MM"
        let mesAtualStr = formatter.string(from: Date())
        
        self.valoresPendentes = todosPagamentos
            .filter { !$0.pago && $0.mesReferencia <= mesAtualStr }
            .reduce(0) { $0 + $1.valor }
    }
    
    // MARK: - Ações com Atualização Otimista
    
    func atualizarStatusDaSessao(sessaoID: String, novoStatus: SessionStatus, novaData: Date? = nil, userId: String) {
        if let index = sessoesHoje.firstIndex(where: { $0.id == sessaoID }) {
            
            Task {
                // 1. Verificação de Conflitos
                if let novaData = novaData, novoStatus == .adiada {
                    if let conflito = try? await verificarConflito(novaData: novaData, ignorandoSessaoID: sessaoID, userId: userId) {
                        await MainActor.run {
                            self.mensagemConflito = "Este horário conflita com a sessão de \(conflito.nome) às \(conflito.hora)."
                            self.mostrarAlertaConflito = true
                        }
                        return
                    }
                }
                
                // 2. Modificação e Atualização Otimista imediata na UI
                var sessaoAtualizada = sessoesHoje[index]
                sessaoAtualizada.status = novoStatus
                
                if let novaData = novaData, novoStatus == .adiada {
                    sessaoAtualizada.dataDaSessão = novaData
                    sessaoAtualizada.sessaoFixaID = nil
                    
                    let formatter = DateFormatter()
                    formatter.dateFormat = "HH:mm"
                    sessaoAtualizada.horaInicio = formatter.string(from: novaData)
                    
                    if Calendar.current.isDateInToday(novaData) {
                        sessaoAtualizada.status = .agendada
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
                
                // 3. Persistência em background
                try? await sessionRepository.atualizarSessao(sessaoAtualizada, userId: userId)
            }
        }
    }
    
    private func verificarConflito(novaData: Date, ignorandoSessaoID: String, userId: String) async throws -> (nome: String, hora: String)? {
        let calendar = Calendar.current
        let formatador = DateFormatter()
        formatador.dateFormat = "HH:mm"
        
        let novaHoraStr = formatador.string(from: novaData)
        let minutosNovaSessao = converterParaMinutos(novaHoraStr)
        
        let sessoesParaValidar = todasSessoes // Usa o cache local em vez de nova requisição
        
        for sessao in sessoesParaValidar {
            if sessao.id == ignorandoSessaoID || sessao.status == .cancelada { continue }
            
            if calendar.isDate(sessao.dataDaSessão, inSameDayAs: novaData) {
                let minutosSessaoExistente = converterParaMinutos(sessao.horaInicio)
                
                if abs(minutosNovaSessao - minutosSessaoExistente) < 60 {
                    if let pacienteConflito = pacientes.first(where: { $0.id == sessao.pacienteID }) {
                        return (nome: pacienteConflito.nome, hora: sessao.horaInicio)
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
            return try await service.horariosLivresParaSessaoAvulsa(
                data: data,
                ignorandoSessaoID: sessaoID,
                derivadaDeContratoID: sessaoAtual?.sessaoFixaID,
                userId: userId
            )
        } catch {
            print("Erro ao buscar horários livres: \(error.localizedDescription)")
            return []
        }
    }
    
    // MARK: - Propriedades Computadas e Helpers
    
    var primeiraDataComConflito: Date? {
        let sessoesAtivas = todasSessoes.filter { $0.status != .cancelada }
        var agrupamento: [String: [Session]] = [:]
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        
        for sessao in sessoesAtivas {
            let chaveDeTempo = formatter.string(from: sessao.dataDaSessão) + "-" + sessao.horaInicio
            agrupamento[chaveDeTempo, default: []].append(sessao)
        }
        
        return agrupamento.values.filter { $0.count > 1 }.compactMap { $0.first?.dataDaSessão }.sorted().first
    }
    
    var slidesAtivos: [HomeSlide] {
        var slides: [HomeSlide] = []
        if proximaSessao != nil { slides.append(.proximaSessao) } else { slides.append(.resumo) }
        if primeiraDataComConflito != nil { slides.append(.conflito) }
        if primeiraPendenciaAtrasada != nil { slides.append(.pendencias) }
        return slides
    }
    
    var proximaSessao: Session? {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        let horaAtual = formatter.string(from: Date())
        
        return sessoesHoje.first { sessao in
            sessao.horaInicio >= horaAtual && sessao.status == .agendada
        }
    }
    
    var nomePacienteProximaSessao: String {
        guard let proxima = proximaSessao,
              let paciente = pacientes.first(where: { $0.id == proxima.pacienteID }) else {
            return "Paciente não encontrado"
        }
        return paciente.nome
    }
    
    var totalSessoesHojeText: String {
        return "\(sessoesHoje.count)"
    }
    
    var valoresPendentesText: String {
        return String(format: "R$ %.0f", valoresPendentes)
    }
    
    func paciente(for session: Session) -> Patient? {
        return pacientes.first(where: { $0.id == session.pacienteID })
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
            let naoEHoje = !calendar.isDateInToday(sessao.dataDaSessão)
            let dentroDaSemana = sessao.dataDaSessão >= inicioDaSemana
            return sessao.status == .realizada && dentroDaSemana && naoEHoje
        }.count
        
        let realizadasHoje = sessoesHoje.filter { $0.status == .realizada }.count
        
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
