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
    
    // Repositórios
    private let patientRepository: PatientRepositoryProtocol
    private let evolutionRepository: EvolutionRepositoryProtocol
    private let paymentRepository: PaymentRepositoryProtocol
    
    init(
        paciente: Patient,
        patientRepository: PatientRepositoryProtocol = MockPatientRepository(),
        evolutionRepository: EvolutionRepositoryProtocol = MockEvolutionRepository(),
        paymentRepository: PaymentRepositoryProtocol = MockPaymentRepository()
    ) {
        self.paciente = paciente
        self.patientRepository = patientRepository
        self.evolutionRepository = evolutionRepository
        self.paymentRepository = paymentRepository
        
        carregarEvolucoes()
        carregarPagamentos()
    }
    
    func carregarEvolucoes() {
        self.evolucoes = evolutionRepository.fetchEvolucoes(paraPacienteID: paciente.id)
    }
    
    func carregarPagamentos() {
        self.pagamentos = paymentRepository.fetchPagamentos(paraPacienteID: paciente.id)
        
        self.pagamentos.sort { $0.mesReferencia > $1.mesReferencia }
    }
    
    func togglePagamento(pagamentoID: String) {
        if let index = pagamentos.firstIndex(where: { $0.id == pagamentoID }) {
            var pagamentoAtualizado = pagamentos[index]
            
            // Inverte o boolean
            pagamentoAtualizado.pago.toggle()
            
            // Se marcou como pago, registra a data de hoje. Se desfez, tira a data.
            pagamentoAtualizado.dataPagamento = pagamentoAtualizado.pago ? Date() : nil
            
            // 1. Manda pro banco de dados salvar
            paymentRepository.atualizarPagamento(pagamentoAtualizado)
            
            // 2. Atualiza a tela (com animação que faremos na View)
            pagamentos[index] = pagamentoAtualizado
        }
    }
    
    func adicionarEvolucao(texto: String) {
        let novaEvolucao = Evolution(id: UUID().uuidString, psicologoID: "user_dev_01", pacienteID: paciente.id, data: Date(), conteudo: texto)
        evolutionRepository.salvarEvolucao(novaEvolucao)
        evolucoes.insert(novaEvolucao, at: 0)
    }
    
    func salvarAlteracoesDoPaciente() {
        patientRepository.atualizarPaciente(paciente)
    }
}
