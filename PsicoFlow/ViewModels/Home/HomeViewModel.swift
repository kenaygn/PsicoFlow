//
//  HomeViewModel.swift
//  PsicoApp
//
//  Created by Kenay on 02/04/26.
//

import SwiftUI
import Foundation
import Combine

/// ViewModel principal do Dashboard (Home).
/// Orquestra a busca e o cruzamento de dados de pacientes, sessões do dia e estado financeiro,
/// alimentando os resumos estatísticos e controlando o fluxo de reagendamento da tela inicial.
class HomeViewModel: ObservableObject {
    
    // Cards que aparecem no slide da home
    enum HomeSlide: Hashable {
        case conflito, proximaSessao, resumo, pendencias
    }
    
    @Published var sessoesHoje: [Session] = []
    @Published var pacientes: [Patient] = []
    
    @Published var valoresPendentes: Double = 0.0
    
    // Alertas e Conflitos
    @Published var mensagemConflito: String = ""
    @Published var mostrarAlertaConflito: Bool = false
    
    private var financeAnalyzer = FinanceAnalyzerService()
    private let availabilityService: AgendaAvailabilityService
    
    private let patientRepository: PatientRepositoryProtocol
    private let sessionRepository: SessionRepositoryProtocol
    private let paymentRepository: PaymentRepositoryProtocol
    private let fixedSessionRepository: FixedSessionRepositoryProtocol
    
    init(
        patientRepository: PatientRepositoryProtocol = MockPatientRepository(),
        sessionRepository: SessionRepositoryProtocol = MockSessionRepository(),
        paymentRepository: PaymentRepositoryProtocol = MockPaymentRepository(),
        fixedSessionRepository: FixedSessionRepositoryProtocol = MockFixedSessionRepository()
    ) {
        self.patientRepository = patientRepository
        self.sessionRepository = sessionRepository
        self.paymentRepository = paymentRepository
        self.fixedSessionRepository = fixedSessionRepository
        
        self.availabilityService = AgendaAvailabilityService(
            fixedSessionRepository: fixedSessionRepository,
            sessionRepository: sessionRepository
        )
        
        carregarDados()
    }
    
    /// Procura se existe algum conflito de agendamento em toda a base de sessões ativas
    var primeiraDataComConflito: Date? {
        // Usa o repositório para buscar todas as sessões que não estão canceladas
        let sessoesAtivas = sessionRepository.fetchSessoes().filter { $0.status != .cancelada }
        
        var agrupamento: [String: [Session]] = [:]
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        
        for sessao in sessoesAtivas {
            let chaveDeTempo = formatter.string(from: sessao.dataDaSessão) + "-" + sessao.horaInicio
            agrupamento[chaveDeTempo, default: []].append(sessao)
        }
        
        // Se houver mais de 1 sessão no mesmo dia e horário, temos um conflito
        let gruposComConflito = agrupamento.values.filter { $0.count > 1 }
        let datasComConflito = gruposComConflito.compactMap { $0.first?.dataDaSessão }
        
        return datasComConflito.sorted().first
    }
    
    /// Verifica quais os cards que estao ativos para aprecerem na Home
    var slidesAtivos: [HomeSlide] {
        var slides: [HomeSlide] = []
        if proximaSessao != nil { slides.append(.proximaSessao) } else { slides.append(.resumo) }
        if primeiraDataComConflito != nil { slides.append(.conflito) }
        if primeiraPendenciaAtrasada != nil { slides.append(.pendencias) }
        return slides
    }
    
    var primeiraPendenciaAtrasada: Date? {
        // Aqui você passaria a lista de pagamentos vinda do seu repositório
        return financeAnalyzer.identificarPrimeiroMesComAtraso(nos: paymentRepository.fetchPagamentos())
    }
    
    var labelPendenciaFinanceira: String {
        guard let data = primeiraPendenciaAtrasada else { return "" }
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "pt_BR")
        formatter.dateFormat = "MMMM/yyyy"
        return formatter.string(from: data).capitalized
    }
    
    /// Busca e sincroniza os dados globais necessários para a visualização da tela inicial.
    func carregarDados() {
        self.pacientes = patientRepository.fetchPacientes()
        
        let todasAsSessoes = sessionRepository.fetchSessoes()
        
        var sessoesDeHoje = todasAsSessoes
            .filter { Calendar.current.isDateInToday($0.dataDaSessão) }
            .sorted { $0.horaInicio < $1.horaInicio }
        
        // Sincronização e correção de status automático:
        // Se uma sessão estava como 'Adiada', mas a nova data caiu no dia de hoje,
        // ela automaticamente retorna para o status de 'Agendada' (pendente).
        for i in 0..<sessoesDeHoje.count {
            if sessoesDeHoje[i].status == .adiada {
                sessoesDeHoje[i].status = .agendada
                sessionRepository.atualizarSessao(sessoesDeHoje[i])
            }
        }
        
        self.sessoesHoje = sessoesDeHoje
        
        // Cálculo Financeiro de Pendências
        let todosPagamentos = paymentRepository.fetchPagamentos()
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy/MM"
        let mesAtualStr = formatter.string(from: Date())
        
        self.valoresPendentes = todosPagamentos
            .filter { !$0.pago && $0.mesReferencia <= mesAtualStr }
            .reduce(0) { $0 + $1.valor }
    }
    
    /// Identifica qual é o atendimento imediatamente a seguir baseado no horário atual.
    var proximaSessao: Session? {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        let horaAtual = formatter.string(from: Date())
        
        return sessoesHoje.first { sessao in
            let eHoje = Calendar.current.isDateInToday(sessao.dataDaSessão)
            let vaiAcontecerAinda = sessao.horaInicio >= horaAtual
            let statusValido = sessao.status == .agendada
            
            return eHoje && vaiAcontecerAinda && statusValido
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
    
    /// Calcula o volume de atendimentos concluídos na semana corrente.
    var atendimentosRealizadosNaSemana: Int {
        let calendar = Calendar.current
        let hoje = Date()
        
        guard let inicioDaSemana = calendar.dateInterval(of: .weekOfYear, for: hoje)?.start else {
            return 0
        }
        
        let realizadasPassadas = sessionRepository.fetchSessoes().filter { sessao in
            let naoEHoje = !calendar.isDateInToday(sessao.dataDaSessão)
            let dentroDaSemana = sessao.dataDaSessão >= inicioDaSemana
            return sessao.status == .realizada && dentroDaSemana && naoEHoje
        }.count
        
        let realizadasHoje = sessoesHoje.filter { $0.status == .realizada }.count
        
        return realizadasPassadas + realizadasHoje
    }
    
    func paciente(for session: Session) -> Patient? {
        return pacientes.first(where: { $0.id == session.pacienteID })
    }
    
    func verificarSeEProximaSessao(_ sessao: Session) -> Bool {
        guard let proxima = proximaSessao else { return false }
        return sessao.id == proxima.id
    }
    
    /// Processa o fluxo de atualização de status, aplicando validações rigorosas de colisão
    /// antes de delegar a mutação ao repositório.
    func atualizarStatusDaSessao(sessaoID: String, novoStatus: SessionStatus, novaData: Date? = nil) {
        if let index = sessoesHoje.firstIndex(where: { $0.id == sessaoID }) {
            
            withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                
                // 1. Verificação de Restrições (Conflitos de Agenda)
                if let novaData = novaData, novoStatus == .adiada {
                    if let conflito = verificarConflito(novaData: novaData, ignorandoSessaoID: sessaoID) {
                        self.mensagemConflito = "Este horário conflita com a sessão de \(conflito.nome) às \(conflito.hora). Escolha um horário com pelo menos 1 hora de diferença."
                        self.mostrarAlertaConflito = true
                        return
                    }
                }
                
                // 2. Modificação de Estado e Regras Temporais
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
                
                // 3. Persistência e Sincronização da UI
                sessionRepository.atualizarSessao(sessaoAtualizada)
                self.carregarDados()
            }
        }
    }
    
    private func converterParaMinutos(_ hora: String) -> Int {
        let partes = hora.split(separator: ":")
        if partes.count == 2, let h = Int(partes[0]), let m = Int(partes[1]) {
            return (h * 60) + m
        }
        return 0
    }
    
    /// Analisa toda a grade de agendamentos buscando superposições num intervalo de 60 minutos.
    private func verificarConflito(novaData: Date, ignorandoSessaoID: String) -> (nome: String, hora: String)? {
        let calendar = Calendar.current
        let formatador = DateFormatter()
        formatador.dateFormat = "HH:mm"
        
        let novaHoraStr = formatador.string(from: novaData)
        let minutosNovaSessao = converterParaMinutos(novaHoraStr)
        
        var todasAsSessoes = sessoesHoje
        let outrasSessoes = sessionRepository.fetchSessoes().filter { mock in
            !sessoesHoje.contains(where: { $0.id == mock.id })
        }
        todasAsSessoes.append(contentsOf: outrasSessoes)
        
        for sessao in todasAsSessoes {
            if sessao.id == ignorandoSessaoID || sessao.status == .cancelada { continue }
            
            if calendar.isDate(sessao.dataDaSessão, inSameDayAs: novaData) {
                let minutosSessaoExistente = converterParaMinutos(sessao.horaInicio)
                
                // Considera um slot padrão de 60 minutos como bloco de atendimento
                if abs(minutosNovaSessao - minutosSessaoExistente) < 60 {
                    if let pacienteConflito = pacientes.first(where: { $0.id == sessao.pacienteID }) {
                        return (nome: pacienteConflito.nome, hora: sessao.horaInicio)
                    }
                }
            }
        }
        return nil
    }
    
    /// Delega a interseção de horários configurados subtraindo os já ocupados no dia alvo.
    func obterHorariosLivres(para data: Date, ignorandoSessaoID sessaoID: String) -> [String] {
        // Busca a sessão atual para extrair o ID do contrato matriz (caso exista),
        // garantindo que ela não bloqueie o seu próprio slot durante um reagendamento.
        let sessaoAtual = sessionRepository.fetchSessoes().first { $0.id == sessaoID }
        
        return availabilityService.horariosLivresParaSessaoAvulsa(
            data: data,
            ignorandoSessaoID: sessaoID,
            derivadaDeContratoID: sessaoAtual?.sessaoFixaID
        )
    }
    
}
