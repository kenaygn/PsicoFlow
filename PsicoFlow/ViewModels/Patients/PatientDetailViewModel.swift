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
            let dados = try await evolutionRepository.fetchEvolucoes(paraPacienteID: paciente.id, userId: userId)
            
            await MainActor.run {
                withAnimation(.spring()) {
                    self.evolucoes = dados
                }
            }
        } catch {
            print("Erro ao carregar evoluções: \(error.localizedDescription)")
        }
    }
    
    func carregarPagamentos(userId: String) async {
        do {
            let dados = try await paymentRepository.fetchPagamentos(userId: userId)
            
            await MainActor.run {
                withAnimation(.spring()) {
                    self.pagamentos = dados.filter { $0.pacienteID == paciente.id }.sorted { $0.mesReferencia > $1.mesReferencia }
                }
            }
        } catch {
            print("Erro ao carregar pagamentos: \(error.localizedDescription)")
        }
    }
    
    func carregarSessoesConfiguradas(userId: String) async {
        do {
            let fixas = try await fixedSessionRepository.fetchSessoesFixas(userId: userId)
            let todasSessoes = try await sessionRepository.fetchSessoes(userId: userId)
            let hoje = Calendar.current.startOfDay(for: Date())
            
            await MainActor.run {
                withAnimation(.spring()) {
                    self.sessoesFixas = fixas.filter { $0.patientID == paciente.id }
                    
                    self.sessoesAvulsasFuturas = todasSessoes.filter { sessao in
                        sessao.patientID == paciente.id &&
                        sessao.fixedSessionID == nil &&
                        (sessao.status == .scheduled || sessao.status == .postponed) &&
                        Calendar.current.startOfDay(for: sessao.sessionDate) >= hoje
                    }
                    .sorted { $0.sessionDate < $1.sessionDate }
                }
            }
        } catch {
            print("Erro ao carregar sessões configuradas: \(error.localizedDescription)")
        }
    }
    
    // MARK: - Ações Locais e Firebase (Com Animação)
    
    func togglePagamento(pagamentoID: String, userId: String) {
        if let index = pagamentos.firstIndex(where: { $0.id == pagamentoID }) {
            var pagamentoAtualizado = pagamentos[index]
            pagamentoAtualizado.pago.toggle()
            pagamentoAtualizado.dataPagamento = pagamentoAtualizado.pago ? Date() : nil
            
            Task {
                do {
                    try await paymentRepository.atualizarPagamento(pagamentoAtualizado, userId: userId)
                    
                    await MainActor.run {
                        withAnimation(.spring()) {
                            self.pagamentos[index] = pagamentoAtualizado
                        }
                    }
                } catch {
                    print("Erro ao atualizar pagamento: \(error.localizedDescription)")
                }
            }
        }
    }
    
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
                
                await MainActor.run {
                    withAnimation(.spring()) {
                        self.evolucoes.insert(novaEvolucao, at: 0)
                    }
                }
            } catch {
                print("Erro ao salvar evolução: \(error.localizedDescription)")
            }
        }
    }
    
    func atualizarEvolucao(evolucaoAtualizada: Evolution, userId: String) {
        Task {
            do {
                try await evolutionRepository.atualizarEvolucao(evolucaoAtualizada, userId: userId)
                
                await MainActor.run {
                    withAnimation(.spring()) {
                        if let index = self.evolucoes.firstIndex(where: { $0.id == evolucaoAtualizada.id }) {
                            self.evolucoes[index] = evolucaoAtualizada
                        }
                    }
                }
            } catch {
                print("Erro ao atualizar evolução: \(error.localizedDescription)")
            }
        }
    }
    
    func deletarEvolucao(id: String, userId: String) {
        Task {
            do {
                try await evolutionRepository.deletarEvolucao(id: id, userId: userId)
                
                await MainActor.run {
                    withAnimation(.spring()) {
                        self.evolucoes.removeAll { $0.id == id }
                    }
                }
            } catch {
                print("Erro ao deletar evolução: \(error.localizedDescription)")
            }
        }
    }
        
    // MARK: - Helpers
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
