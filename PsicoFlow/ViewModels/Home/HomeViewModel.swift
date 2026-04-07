//
//  HomeViewModel.swift
//  PsicoApp
//
//  Created by Kenay on 02/04/26.
//

import SwiftUI
import Foundation
import Combine


class HomeViewModel: ObservableObject {
    @Published var sessoesHoje: [Session] = []
    @Published var pacientes: [Patient] = []
    
    @Published var valoresPendentes: Double = 0.0
    @Published var mensagemConflito: String = ""
    @Published var mostrarAlertaConflito: Bool = false
    
    // Os nossos "Gerentes" injetados
    private let patientRepository: PatientRepositoryProtocol
    private let sessionRepository: SessionRepositoryProtocol
    private let paymentRepository: PaymentRepositoryProtocol
    
    // INJEÇÃO DE DEPENDÊNCIA
    init(
        patientRepository: PatientRepositoryProtocol = MockPatientRepository(),
        sessionRepository: SessionRepositoryProtocol = MockSessionRepository(),
        paymentRepository: PaymentRepositoryProtocol = MockPaymentRepository()
    ) {
        self.patientRepository = patientRepository
        self.sessionRepository = sessionRepository
        self.paymentRepository = paymentRepository
        carregarDados()
    }
    
    func carregarDados() {
        // 1. Puxa pacientes do Repositório
        self.pacientes = patientRepository.fetchPacientes()
        
        // 2. Puxa TODAS as sessões do Repositório
        let todasAsSessoes = sessionRepository.fetchSessoes()
        
        // 3. Filtra e ordena as sessões de hoje
        var sessoesDeHoje = todasAsSessoes
            .filter { Calendar.current.isDateInToday($0.dataDaSessão) }
            .sorted { $0.horaInicio < $1.horaInicio }
        
        // 4. Corrige status adiado
        for i in 0..<sessoesDeHoje.count {
            if sessoesDeHoje[i].status == .adiada {
                sessoesDeHoje[i].status = .agendada
                // Atualiza também no "banco de dados"
                sessionRepository.atualizarSessao(sessoesDeHoje[i])
            }
        }
        
        self.sessoesHoje = sessoesDeHoje
        
        // 5. Puxa pagamentos e calcula pendentes
        let todosPagamentos = paymentRepository.fetchPagamentos()
        
        // Descobre qual é o mês atual no mesmo formato do banco (ex: "2026/04")
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy/MM"
        let mesAtualStr = formatter.string(from: Date())
        
        // Filtra: Não está pago E o mês de referência é menor ou igual ao mês atual
        self.valoresPendentes = todosPagamentos
            .filter { !$0.pago && $0.mesReferencia <= mesAtualStr }
            .reduce(0) { $0 + $1.valor }
    }
    
    // MARK: - Lógica de Próxima Sessão
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
    
    // MARK: - Formatação para os Cards de Estatística
    var totalSessoesHojeText: String {
        return "\(sessoesHoje.count)"
    }
    
    var valoresPendentesText: String {
        return String(format: "R$ %.0f", valoresPendentes)
    }
    
    // MARK: - Funções Auxiliares para a Lista
    func paciente(for session: Session) -> Patient? {
        return pacientes.first(where: { $0.id == session.pacienteID })
    }
    
    func verificarSeEProximaSessao(_ sessao: Session) -> Bool {
        guard let proxima = proximaSessao else { return false }
        return sessao.id == proxima.id
    }
    
    func atualizarStatusDaSessao(sessaoID: String, novoStatus: SessionStatus, novaData: Date? = nil) {
            if let index = sessoesHoje.firstIndex(where: { $0.id == sessaoID }) {
                
                withAnimation(Animation.spring(response: 0.4, dampingFraction: 0.7)) {
                    // 1. Verifica conflitos primeiro
                    if let novaData = novaData, novoStatus == .adiada {
                        if let conflito = verificarConflito(novaData: novaData, ignorandoSessaoID: sessaoID) {
                            self.mensagemConflito = "Este horário conflita com a sessão de \(conflito.nome) às \(conflito.hora). Escolha um horário com pelo menos 1 hora de diferença."
                            self.mostrarAlertaConflito = true
                            return
                        }
                    }
                    
                    // 2. CRIAMOS UMA CÓPIA SEGURA DA SESSÃO
                    var sessaoAtualizada = sessoesHoje[index]
                    
                    // 3. Atualizamos os dados na nossa cópia
                    sessaoAtualizada.status = novoStatus
                    
                    if let novaData = novaData, novoStatus == .adiada {
                        sessaoAtualizada.dataDaSessão = novaData
                        let formatter = DateFormatter()
                        formatter.dateFormat = "HH:mm"
                        sessaoAtualizada.horaInicio = formatter.string(from: novaData)
                        
                        if Calendar.current.isDateInToday(novaData) {
                            sessaoAtualizada.status = .agendada
                        }
                    }
                    
                    // 4. MANDA O BANCO DE DADOS SALVAR A CÓPIA DIRETA
                    // Sem risco de usar index errado!
                    sessionRepository.atualizarSessao(sessaoAtualizada)
                    
                    // 5. Recarrega a lista toda fresca do banco de dados
                    // O carregarDados() já faz o sort automático e atualiza a UI
                    self.carregarDados()
                }
            }
        }
    
    // MARK: - Gamificação (Resumo da Semana)
    var atendimentosRealizadosNaSemana: Int {
        let calendar = Calendar.current
        let hoje = Date()
        
        guard let inicioDaSemana = calendar.dateInterval(of: .weekOfYear, for: hoje)?.start else {
            return 0
        }
        
        // Agora busca pelo repositório!
        let realizadasPassadas = sessionRepository.fetchSessoes().filter { sessao in
            let naoEHoje = !calendar.isDateInToday(sessao.dataDaSessão)
            let dentroDaSemana = sessao.dataDaSessão >= inicioDaSemana
            return sessao.status == .realizada && dentroDaSemana && naoEHoje
        }.count
        
        let realizadasHoje = sessoesHoje.filter { $0.status == .realizada }.count
        return realizadasPassadas + realizadasHoje
    }
    
    // MARK: - Verificação de Conflitos
    private func converterParaMinutos(_ hora: String) -> Int {
        let partes = hora.split(separator: ":")
        if partes.count == 2, let h = Int(partes[0]), let m = Int(partes[1]) {
            return (h * 60) + m
        }
        return 0
    }
    
    private func verificarConflito(novaData: Date, ignorandoSessaoID: String) -> (nome: String, hora: String)? {
        let calendar = Calendar.current
        let formatador = DateFormatter()
        formatador.dateFormat = "HH:mm"
        
        let novaHoraStr = formatador.string(from: novaData)
        let minutosNovaSessao = converterParaMinutos(novaHoraStr)
        
        var todasAsSessoes = sessoesHoje
        // Busca as outras sessões no repositório!
        let outrasSessoes = sessionRepository.fetchSessoes().filter { mock in
            !sessoesHoje.contains(where: { $0.id == mock.id })
        }
        todasAsSessoes.append(contentsOf: outrasSessoes)
        
        for sessao in todasAsSessoes {
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
}
