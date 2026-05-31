//
//  PatientFormViewModel.swift
//  PsicoFlow
//
//  Created by Kenay on 06/04/26.
//

import Foundation
import Combine

class PatientFormViewModel: ObservableObject {
    
    @Published var nome: String = ""
    @Published var email: String = ""
    @Published var telefone: String = ""
    @Published var contatoEmergencia: String = ""
    @Published var valorTexto: String = ""
    @Published var status: PatientStatus = .ativo
    @Published var observacoes: String = ""
    
    private var pacienteOriginal: Patient?
    
    private let patientRepository: PatientRepositoryProtocol
    
    // Serviços de Domínio Especializados
    private let sessionGenerator: SessionGeneratorService
    private let paymentService: MonthlyPaymentGeneratorService
    
    init(
        paciente: Patient? = nil,
        patientRepository: PatientRepositoryProtocol = MockPatientRepository(),
        sessionRepository: SessionRepositoryProtocol = MockSessionRepository(),
        fixedSessionRepository: FixedSessionRepositoryProtocol = MockFixedSessionRepository(),
        paymentRepository: PaymentRepositoryProtocol = MockPaymentRepository()
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
        
        // Inicializa os serviços injetando os repositórios
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
    
    func obterPacienteAtualizado() -> Patient {
        let valorConvertido = Double(valorTexto.replacingOccurrences(of: ",", with: ".")) ?? 0.0
        
        return Patient(
            id: pacienteOriginal?.id ?? UUID().uuidString,
            psicologoID: pacienteOriginal?.psicologoID ?? "user_dev_01",
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
    
    func salvar() {
            let pacienteAtualizado = obterPacienteAtualizado()
            
            // 1. Persiste a alteração no banco de dados
            patientRepository.atualizarPaciente(pacienteAtualizado)
            
            // 2. Delega a atualização da agenda para o serviço responsável
            sessionGenerator.projetarSessoesFuturas()
            
            // 3. Regras Financeiras de Status
            let statusAntigo = pacienteOriginal?.status ?? .ativo
            let isNovoPaciente = pacienteOriginal == nil
            
            if statusAntigo == .ativo && pacienteAtualizado.status == .inativo {
                // Cenário A: O paciente acabou de ser INATIVADO. Limpa as cobranças pendentes.
                paymentService.removerCobrancasPendentes(para: pacienteAtualizado.id)
                
            } else if (statusAntigo == .inativo && pacienteAtualizado.status == .ativo) || isNovoPaciente {
                // Cenário B: O paciente foi REATIVADO ou é um paciente RECÉM-CRIADO.
                // Roda o motor geral. O serviço vai ver que ele está ativo, notar que
                // faltam as faturas deste mês e do próximo, e gerá-las na hora!
                paymentService.gerarCobrancasAtuaisEFuturas()
            }
        }
}
