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
        
    @Published var sessoesHoje: [Session] = []
    @Published var pacientes: [Patient] = []
    
    @Published var valoresPendentes: Double = 0.0
    
    // Alertas e Conflitos
    @Published var mensagemConflito: String = ""
    @Published var mostrarAlertaConflito: Bool = false
        
    private let patientRepository: PatientRepositoryProtocol
    private let sessionRepository: SessionRepositoryProtocol
    private let paymentRepository: PaymentRepositoryProtocol
        
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
    
    // Note: Esta é a mesma matriz de horários utilizada na `EditSessionViewModel`.
    // Futuramente, externalize essa lista para uma estrutura unificada (`AppConfig`)
    // ou busque diretamente dos limites operacionais configurados pelo psicólogo no banco de dados.
    private let todosHorarios: [String] = [
        "07:00", "08:00", "09:00", "10:00", "11:00", "12:00",
        "13:00", "14:00", "15:00", "16:00", "17:00", "18:00", "19:00", "20:00", "21:00", "22:00"
    ]
    
    /// Calcula a intersecção de horários configurados subtraindo os já ocupados no dia alvo.
    func obterHorariosLivres(para data: Date, ignorandoSessaoID sessaoID: String) -> [String] {
        let sessoesNoMesmoDia = sessionRepository.fetchSessoes().filter {
            Calendar.current.isDate($0.dataDaSessão, inSameDayAs: data) &&
            $0.status != .cancelada &&
            $0.id != sessaoID
        }
        
        let ocupados = sessoesNoMesmoDia.map { $0.horaInicio }
        return todosHorarios.filter { !ocupados.contains($0) }
    }
}
