//
//  PatientDetailViewModel.swift
//  PsicoFlow
//
//  Created by Kenay on 04/04/26.
//

import Foundation
import SwiftUI
import Combine

/// ViewModel responsável por agregar e gerenciar todas as informações do prontuário
/// de um paciente específico (Detalhes, Evoluções, Pagamentos e Agendamentos).
class PatientDetailViewModel: ObservableObject {
        
    @Published var paciente: Patient
    @Published var evolucoes: [Evolution] = []
    @Published var pagamentos: [MonthlyPayment] = []
    @Published var sessoesFixas: [FixedSession] = []
    @Published var sessoesAvulsasFuturas: [Session] = []
        
    private let patientRepository: PatientRepositoryProtocol
    private let evolutionRepository: EvolutionRepositoryProtocol
    private let paymentRepository: PaymentRepositoryProtocol
    private let fixedSessionRepository: FixedSessionRepositoryProtocol
    private let sessionRepository: SessionRepositoryProtocol
            
    init(
        paciente: Patient,
        patientRepository: PatientRepositoryProtocol = MockPatientRepository(),
        evolutionRepository: EvolutionRepositoryProtocol = MockEvolutionRepository(),
        paymentRepository: PaymentRepositoryProtocol = MockPaymentRepository(),
        fixedSessionRepository: FixedSessionRepositoryProtocol = MockFixedSessionRepository(),
        sessionRepository: SessionRepositoryProtocol = MockSessionRepository()
    ) {
        self.paciente = paciente
        self.patientRepository = patientRepository
        self.evolutionRepository = evolutionRepository
        self.paymentRepository = paymentRepository
        self.fixedSessionRepository = fixedSessionRepository
        self.sessionRepository = sessionRepository
        
        carregarDadosCompletos()
    }
        
    /// Orquestra o carregamento de todos os módulos de dados atrelados ao paciente.
    func carregarDadosCompletos() {
        carregarEvolucoes()
        carregarPagamentos()
        carregarSessoesConfiguradas()
    }
    
    func carregarEvolucoes() {
        self.evolucoes = evolutionRepository.fetchEvolucoes(paraPacienteID: paciente.id)
    }
    
    func carregarPagamentos() {
        self.pagamentos = paymentRepository.fetchPagamentos(paraPacienteID: paciente.id)
        self.pagamentos.sort { $0.mesReferencia > $1.mesReferencia }
    }
    
    /// Busca contratos recorrentes e sessões únicas futuras, aplicando as regras de filtragem visual.
    func carregarSessoesConfiguradas() {
        // Contratos fixos (Recorrentes)
        self.sessoesFixas = fixedSessionRepository.fetchSessoesFixas().filter { $0.pacienteID == paciente.id }
        
        // Sessões avulsas futuras
        let hoje = Calendar.current.startOfDay(for: Date())
        
        self.sessoesAvulsasFuturas = sessionRepository.fetchSessoes().filter { sessao in
            sessao.pacienteID == paciente.id &&
            sessao.sessaoFixaID == nil &&
            (sessao.status == .agendada || sessao.status == .adiada) &&
            Calendar.current.startOfDay(for: sessao.dataDaSessão) >= hoje
        }
        .sorted { $0.dataDaSessão < $1.dataDaSessão }
    }
        
    /// Alterna o status de pagamento de uma mensalidade e persiste a alteração.
    func togglePagamento(pagamentoID: String) {
        if let index = pagamentos.firstIndex(where: { $0.id == pagamentoID }) {
            var pagamentoAtualizado = pagamentos[index]
            pagamentoAtualizado.pago.toggle()
            pagamentoAtualizado.dataPagamento = pagamentoAtualizado.pago ? Date() : nil
            
            paymentRepository.atualizarPagamento(pagamentoAtualizado)
            pagamentos[index] = pagamentoAtualizado
        }
    }
    
    /// Cria e persiste uma nova evolução clínica para o paciente.
    func adicionarEvolucao(texto: String) {
        // Note: O 'psicologoID' ("user_dev_01") está fixo. Em produção, este valor
        // deve ser injetado através do serviço de Autenticação/Sessão do usuário.
        let novaEvolucao = Evolution(
            id: UUID().uuidString,
            psicologoID: "user_dev_01",
            pacienteID: paciente.id,
            data: Date(),
            conteudo: texto
        )
        
        evolutionRepository.salvarEvolucao(novaEvolucao)
        evolucoes.insert(novaEvolucao, at: 0)
    }
        
    /// Converte o index inteiro de um dia da semana para sua representação nominal em português.
    func nomeDoDiaDaSemana(_ dia: Int) -> String {
        let diasEmPortugues = [
            "Domingo", "Segunda-feira", "Terça-feira",
            "Quarta-feira", "Quinta-feira", "Sexta-feira", "Sábado"
        ]
        
        if dia >= 1 && dia <= 7 {
            return diasEmPortugues[dia - 1]
        }
        return "Dia Indefinido"
    }
}
