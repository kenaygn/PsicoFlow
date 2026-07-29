//
//  PatientFormViewModel.swift
//  PsicoFlow
//
//  Created by Kenay on 06/04/26.
//

import Foundation
import Combine

@MainActor
class PatientFormViewModel: ObservableObject {
    
    @Published var nome: String = ""
    @Published var email: String = ""
    @Published var telefone: String = ""
    @Published var contatoEmergencia: String = ""
    @Published var valorTexto: String = ""
    @Published var status: PatientStatus = .ativo
    @Published var observacoes: String = ""
    
    @Published var estaExcluindo: Bool = false
    
    private var pacienteOriginal: Patient?
    
    private let patientRepository: PatientRepositoryProtocol
    private let sessionGenerator: SessionGeneratorService
    private let paymentService: MonthlyPaymentGeneratorService
    
    init(
        paciente: Patient? = nil,
        patientRepository: PatientRepositoryProtocol = PatientFirebaseRepository(),
        sessionRepository: SessionRepositoryProtocol = SessionFirebaseRepository(),
        fixedSessionRepository: FixedSessionRepositoryProtocol = FixedSessionFirebaseRepository(),
        paymentRepository: PaymentRepositoryProtocol = PaymentFirebaseRepository()
    ) {
        self.pacienteOriginal = paciente
        self.patientRepository = patientRepository
        
        if let paciente = paciente {
            self.nome = paciente.nome
            self.email = paciente.email
            self.telefone = paciente.telefone
            self.contatoEmergencia = paciente.contatoEmergencia ?? ""
            self.status = paciente.status
            self.observacoes = paciente.observacoes ?? ""
            
            let valorString = String(format: "%.2f", paciente.valor).replacingOccurrences(of: ".", with: ",")
            self.valorTexto = valorString
        }
        
        self.sessionGenerator = SessionGeneratorService(
            patientRepository: patientRepository,
            fixedSessionRepository: fixedSessionRepository,
            sessionRepository: sessionRepository
        )
        
        self.paymentService = MonthlyPaymentGeneratorService(
            patientRepository: patientRepository,
            paymentRepository: paymentRepository
        )
    }
    
    var isFormValid: Bool {
        let nomePreenchido = !nome.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        let valorValido = Double(valorTexto.replacingOccurrences(of: ",", with: ".")) != nil
        return nomePreenchido && valorValido
    }
    
    func obterPacienteAtualizado(userId: String) -> Patient {
        let valorConvertido = Double(valorTexto.replacingOccurrences(of: ",", with: ".")) ?? 0.0
        
        return Patient(
            id: pacienteOriginal?.id ?? UUID().uuidString,
            psicologoID: userId,
            nome: nome,
            email: email,
            telefone: telefone,
            contatoEmergencia: contatoEmergencia.isEmpty ? nil : contatoEmergencia,
            observacoes: observacoes.isEmpty ? nil : observacoes,
            status: status,
            valor: valorConvertido,
            criadoEm: pacienteOriginal?.criadoEm ?? Date()
        )
    }
    
    func salvar(userId: String) {
        let pacienteAtualizado = obterPacienteAtualizado(userId: userId)
        let statusAntigo = pacienteOriginal?.status ?? .ativo
        let isNovoPaciente = pacienteOriginal == nil
        
        Task {
            do {
                try await patientRepository.atualizarPaciente(pacienteAtualizado, userId: userId)
                
                try await sessionGenerator.projetarSessoesFuturas(userId: userId)
                
                if statusAntigo == .ativo && pacienteAtualizado.status == .inativo {
                    try await paymentService.removerCobrancasPendentes(para: pacienteAtualizado.id, userId: userId)
                } else if (statusAntigo == .inativo && pacienteAtualizado.status == .ativo) || isNovoPaciente {
                    try await paymentService.gerarCobrancasAtuaisEFuturas(userId: userId)
                }
                
                let precoMudou = pacienteOriginal != nil && pacienteOriginal!.valor != pacienteAtualizado.valor
                
                if statusAntigo == .ativo && pacienteAtualizado.status == .ativo && precoMudou {
                    // Chama o serviço para atualizar os pagamentos pendentes no Firebase
                    try await paymentService.atualizarValorPagamentosPendentes(
                        pacienteID: pacienteAtualizado.id,
                        novoValor: pacienteAtualizado.valor,
                        userId: userId
                    )
                }
                
            } catch {
                print("Erro ao processar salvamento do paciente: \(error.localizedDescription)")
            }
        }
    }
    
    func excluirPaciente(userId: String) async -> Bool {
        // Pega o ID do paciente original (que veio da tela anterior)
        guard let id = pacienteOriginal?.id else { return false }
        
        self.estaExcluindo = true
        
        do {
            // Fazemos o cast para o FirebaseRepository para acessar a função de cascata que criamos
            if let repo = patientRepository as? PatientFirebaseRepository {
                try await repo.excluirPacienteEmCascata(pacienteID: id, userId: userId)
                
                self.estaExcluindo = false
                return true // Retorna true para a View fechar a tela
            }
            return false
        } catch {
            print("Erro ao excluir paciente em cascata: \(error.localizedDescription)")
            self.estaExcluindo = false
            return false
        }
    }
}
