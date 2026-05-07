//
//  PatientDetailViewModel.swift
//  PsicoFlow
//
//  Created by Kenay on 04/04/26.
//

import Foundation
import SwiftUI
import Combine

class PatientDetailViewModel: ObservableObject {
    @Published var paciente: Patient
    @Published var evolucoes: [Evolution] = []
    @Published var pagamentos: [MonthlyPayment] = []
    @Published var sessoesFixas: [FixedSession] = []
    @Published var sessoesAvulsasFuturas: [Session] = []
    
    // Repositórios
    private let patientRepository: PatientRepositoryProtocol
    private let evolutionRepository: EvolutionRepositoryProtocol
    private let paymentRepository: PaymentRepositoryProtocol
    private let fixedSessionRepository: FixedSessionRepositoryProtocol
    private let sessionRepository: SessionRepositoryProtocol
    
    private let generatorService = SessionGeneratorService()
    
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
    
    // MARK: - Carregamento de Dados
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
    
    func carregarSessoesConfiguradas() {
        // 1. Busca os contratos fixos (Recorrentes) do paciente
        self.sessoesFixas = fixedSessionRepository.fetchSessoesFixas().filter { $0.pacienteID == paciente.id }
        
        // 2. Busca as sessões avulsas (que não têm sessaoFixaID) e aplica as regras de negócio
        let hoje = Calendar.current.startOfDay(for: Date())
        
        self.sessoesAvulsasFuturas = sessionRepository.fetchSessoes().filter { sessao in
            sessao.pacienteID == paciente.id &&
            sessao.sessaoFixaID == nil && // Pega apenas as Avulsas
            (sessao.status == .agendada || sessao.status == .adiada) && // Ignora canceladas e realizadas
            Calendar.current.startOfDay(for: sessao.dataDaSessão) >= hoje // REGRA: Apenas datas >= hoje
        }
        .sorted { $0.dataDaSessão < $1.dataDaSessão } // Ordena da mais próxima pra mais distante
    }
    
    // MARK: - Ações e Formatações
    
    func togglePagamento(pagamentoID: String) {
        if let index = pagamentos.firstIndex(where: { $0.id == pagamentoID }) {
            var pagamentoAtualizado = pagamentos[index]
            pagamentoAtualizado.pago.toggle()
            pagamentoAtualizado.dataPagamento = pagamentoAtualizado.pago ? Date() : nil
            paymentRepository.atualizarPagamento(pagamentoAtualizado)
            pagamentos[index] = pagamentoAtualizado
        }
    }
    
    func adicionarEvolucao(texto: String) {
        let novaEvolucao = Evolution(id: UUID().uuidString, psicologoID: "user_dev_01", pacienteID: paciente.id, data: Date(), conteudo: texto)
        evolutionRepository.salvarEvolucao(novaEvolucao)
        evolucoes.insert(novaEvolucao, at: 0)
    }
    
    func salvarAlteracoesDoPaciente() {
            // 1. Salva o paciente no banco de dados (mock)
            patientRepository.atualizarPaciente(paciente)
            
            // 2. Dispara a inteligência de negócios para ajustar a agenda
            generatorService.sincronizarSessoesPorStatus(
                do: paciente,
                regrasFixas: fixedSessionRepository.fetchSessoesFixas(),
                sessionRepository: sessionRepository
            )
            
            // 3. Força a ViewModel a recarregar as listas da tela para mostrar o novo cenário
            carregarSessoesConfiguradas()
        }
    
    // Helper para converter Dia 2 em "Segunda-feira"
    func nomeDoDiaDaSemana(_ dia: Int) -> String {
        let diasEmPortugues = [
            "Domingo", "Segunda-feira", "Terça-feira",
            "Quarta-feira", "Quinta-feira", "Sexta-feira", "Sábado"
        ]
        
        if dia >= 1 && dia <= 7 {
            // dia 1 = Domingo (índice 0)
            return diasEmPortugues[dia - 1]
        }
        return "Dia Indefinido"
    }
}
