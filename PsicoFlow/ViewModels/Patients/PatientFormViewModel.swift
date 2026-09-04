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
    @Published var status: PatientStatus = .active
    @Published var observacoes: String = ""
    
    @Published var estaExcluindo: Bool = false
    
    @Published var mostrarAlertaLimite: Bool = false
    
    private var pacienteOriginal: Patient?
    private let idGerado: String = UUID().uuidString
    
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
            self.nome = paciente.name
            self.email = paciente.email
            self.telefone = paciente.phone
            self.contatoEmergencia = paciente.emergencyContact ?? ""
            self.status = paciente.status
            self.observacoes = paciente.notes ?? ""
            
            let valorString = String(format: "%.2f", paciente.value).replacingOccurrences(of: ".", with: ",")
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
            id: pacienteOriginal?.id ?? idGerado,
            psychologistID: userId,
            name: nome,
            email: email,
            phone: telefone,
            emergencyContact: contatoEmergencia.isEmpty ? nil : contatoEmergencia,
            notes: observacoes.isEmpty ? nil : observacoes,
            status: status,
            value: valorConvertido,
            createdAt: pacienteOriginal?.createdAt ?? Date()
        )
    }
    
    func salvar(userId: String, isPremium: Bool) async -> Bool {
        
        let isNovoAtivo = pacienteOriginal == nil && status == .active
        let isReativando = pacienteOriginal?.status == .inactive && status == .active
        let isAtivando = isNovoAtivo || isReativando
        
        if isAtivando && !isPremium {
            do {
                let todosPacientes = try await patientRepository.fetchPatients(userId: userId)
                let totalAtivos = todosPacientes.filter { $0.status == .active }.count
                
                if totalAtivos >= 5 {
                    self.mostrarAlertaLimite = true
                    return false
                }
            } catch {
                print("Erro ao verificar limite de pacientes: \(error.localizedDescription)")
                return false
            }
        }
        
        let pacienteAtualizado = obterPacienteAtualizado(userId: userId)
        let statusAntigo = pacienteOriginal?.status ?? .active
        let isNovoPaciente = pacienteOriginal == nil
        
        do {
            try await patientRepository.updatePatient(pacienteAtualizado, userId: userId)
            
            try await sessionGenerator.projectFutureSessions(userId: userId)
            
            if statusAntigo == .active && pacienteAtualizado.status == .inactive {
                try await paymentService.removerCobrancasPendentes(para: pacienteAtualizado.id, userId: userId)
            } else if (statusAntigo == .inactive && pacienteAtualizado.status == .active) || isNovoPaciente {
                try await paymentService.gerarCobrancasAtuaisEFuturas(userId: userId)
            }
            
            let precoMudou = pacienteOriginal != nil && pacienteOriginal!.value != pacienteAtualizado.value
            
            if statusAntigo == .active && pacienteAtualizado.status == .active && precoMudou {
                try await paymentService.atualizarValorPagamentosPendentes(
                    pacienteID: pacienteAtualizado.id,
                    novoValor: pacienteAtualizado.value,
                    userId: userId
                )
            }
            
            return true
            
        } catch {
            print("Erro ao processar salvamento do paciente: \(error.localizedDescription)")
            return false
        }
    }
    
    func excluirPaciente(userId: String) async -> Bool {
        // Pega o ID do paciente original (que veio da tela anterior)
        guard let id = pacienteOriginal?.id else { return false }
        
        self.estaExcluindo = true
        
        do {
            // Fazemos o cast para o FirebaseRepository para acessar a função de cascata que criamos
            if let repo = patientRepository as? PatientFirebaseRepository {
                try await repo.deletePatientCascade(patientID: id, userId: userId)
                
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
