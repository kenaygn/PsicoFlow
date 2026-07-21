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
/// de um paciente específico, agora operando com persistência assíncrona (Firebase).
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
        patientRepository: PatientRepositoryProtocol = PatientFirebaseRepository(),
        evolutionRepository: EvolutionRepositoryProtocol = EvolutionFirebaseRepository(),
        paymentRepository: PaymentRepositoryProtocol = PaymentFirebaseRepository(),
        fixedSessionRepository: FixedSessionRepositoryProtocol = FixedSessionFirebaseRepository(),
        sessionRepository: SessionRepositoryProtocol = SessionFirebaseRepository()
    ) {
        self.paciente = paciente
        self.patientRepository = patientRepository
        self.evolutionRepository = evolutionRepository
        self.paymentRepository = paymentRepository
        self.fixedSessionRepository = fixedSessionRepository
        self.sessionRepository = sessionRepository
    }
        
    /// Orquestra o carregamento de todos os módulos de dados atrelados ao paciente.
    func carregarDadosCompletos(userId: String) {
        Task {
            await carregarEvolucoes(userId: userId)
            await carregarPagamentos(userId: userId)
            await carregarSessoesConfiguradas(userId: userId)
        }
    }
    
    func carregarEvolucoes(userId: String) async {
        do {
            self.evolucoes = try await evolutionRepository.fetchEvolucoes(paraPacienteID: paciente.id, userId: userId)
        } catch {
            print("Erro ao carregar evoluções: \(error.localizedDescription)")
        }
    }
    
    func carregarPagamentos(userId: String) async {
        do {
            let dados = try await paymentRepository.fetchPagamentos(userId: userId)
            self.pagamentos = dados.filter { $0.pacienteID == paciente.id }.sorted { $0.mesReferencia > $1.mesReferencia }
        } catch {
            print("Erro ao carregar pagamentos: \(error.localizedDescription)")
        }
    }
    
    /// Busca contratos recorrentes e sessões únicas futuras no Firebase.
    func carregarSessoesConfiguradas(userId: String) async {
        do {
            let fixas = try await fixedSessionRepository.fetchSessoesFixas(userId: userId)
            self.sessoesFixas = fixas.filter { $0.pacienteID == paciente.id }
            
            let todasSessoes = try await sessionRepository.fetchSessoes(userId: userId)
            let hoje = Calendar.current.startOfDay(for: Date())
            
            self.sessoesAvulsasFuturas = todasSessoes.filter { sessao in
                sessao.pacienteID == paciente.id &&
                sessao.sessaoFixaID == nil &&
                (sessao.status == .agendada || sessao.status == .adiada) &&
                Calendar.current.startOfDay(for: sessao.dataDaSessão) >= hoje
            }
            .sorted { $0.dataDaSessão < $1.dataDaSessão }
        } catch {
            print("Erro ao carregar sessões configuradas: \(error.localizedDescription)")
        }
    }
        
    /// Alterna o status de pagamento de uma mensalidade e persiste no Firebase.
    func togglePagamento(pagamentoID: String, userId: String) {
        if let index = pagamentos.firstIndex(where: { $0.id == pagamentoID }) {
            var pagamentoAtualizado = pagamentos[index]
            pagamentoAtualizado.pago.toggle()
            pagamentoAtualizado.dataPagamento = pagamentoAtualizado.pago ? Date() : nil
            
            Task {
                do {
                    try await paymentRepository.atualizarPagamento(pagamentoAtualizado, userId: userId)
                    self.pagamentos[index] = pagamentoAtualizado
                } catch {
                    print("Erro ao atualizar pagamento: \(error.localizedDescription)")
                }
            }
        }
    }
    
    /// Cria e persiste uma nova evolução clínica no Firebase.
    func adicionarEvolucao(texto: String, userId: String) {
        let novaEvolucao = Evolution(
            id: UUID().uuidString,
            psicologoID: userId,
            pacienteID: paciente.id,
            data: Date(),
            conteudo: texto
        )
        
        Task {
            do {
                try await evolutionRepository.salvarEvolucao(novaEvolucao, userId: userId)
                self.evolucoes.insert(novaEvolucao, at: 0)
            } catch {
                print("Erro ao salvar evolução: \(error.localizedDescription)")
            }
        }
    }
        
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
