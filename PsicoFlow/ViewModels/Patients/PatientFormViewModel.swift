//
//  PatientFormViewModel.swift
//  PsicoFlow
//
//  Created by Kenay on 06/04/26.
//

import Foundation
import Combine

/// ViewModel responsável pelo controle de estado e validação do formulário de pacientes.
/// Suporta o reaproveitamento de interface (UI) operando em dois modos dinâmicos:
/// Criação (paciente == nil) e Edição (paciente != nil).
class PatientFormViewModel: ObservableObject {
    
    @Published var nome: String = ""
    @Published var email: String = ""
    @Published var telefone: String = ""
    @Published var contatoEmergencia: String = ""
    @Published var valorTexto: String = ""
    @Published var status: PatientStatus = .ativo
    @Published var observacoes: String = ""
    
    /// Armazena o estado original para preservar identificadores imutáveis (ID e data de criação) durante atualizações.
    private var pacienteOriginal: Patient?
    
    private let patientRepository: PatientRepositoryProtocol
    private let sessionRepository: SessionRepositoryProtocol
    private let fixedSessionRepository: FixedSessionRepositoryProtocol
    
    private let sessionGenerator: SessionGeneratorService
    
    init(
        paciente: Patient? = nil,
        patientRepository: PatientRepositoryProtocol = MockPatientRepository(),
        sessionRepository: SessionRepositoryProtocol = MockSessionRepository(),
        fixedSessionRepository: FixedSessionRepositoryProtocol = MockFixedSessionRepository()
    ) {
        self.pacienteOriginal = paciente
        self.patientRepository = patientRepository
        self.sessionRepository = sessionRepository
        self.fixedSessionRepository = fixedSessionRepository
        
        if let paciente = paciente {
            self.nome = paciente.nome
            self.email = paciente.email
            self.telefone = paciente.telefone
            self.contatoEmergencia = paciente.contatoEmergencia ?? ""
            self.status = paciente.status
            self.observacoes = paciente.observacoes ?? ""
            
            // Note: Para formatação monetária robusta e escalável, considere migrar
            // para um NumberFormatter com o estilo '.currency' no futuro.
            // A substituição direta de caracteres atende bem a MVPs focados no Brasil (pt_BR).
            let valorString = String(format: "%.2f", paciente.valor).replacingOccurrences(of: ".", with: ",")
            self.valorTexto = valorString
        }
        
        self.sessionGenerator = SessionGeneratorService(
            patientRepository: patientRepository,
            fixedSessionRepository: fixedSessionRepository,
            sessionRepository: sessionRepository
        )
    }
    
    /// Retorna verdadeiro se os campos obrigatórios atenderem às regras de negócio e tipagem.
    var isFormValid: Bool {
        let nomePreenchido = !nome.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        let valorValido = Double(valorTexto.replacingOccurrences(of: ",", with: ".")) != nil
        
        return nomePreenchido && valorValido
    }
    
    /// Constrói e retorna uma instância de `Patient` com os dados atuais do formulário.
    /// Preserva automaticamente o `id` e a data de criação caso seja uma operação de edição.
    func obterPacienteAtualizado() -> Patient {
        let valorConvertido = Double(valorTexto.replacingOccurrences(of: ",", with: ".")) ?? 0.0
        
        // Note: O 'psicologoID' está hardcoded temporariamente.
        // Em um ambiente de produção (Firebase/Supabase), este valor deve ser extraído
        // do gerenciador de sessão (ex: AuthService.shared.currentUserId).
        return Patient(
            id: pacienteOriginal?.id ?? UUID().uuidString,
            psicologoID: pacienteOriginal?.psicologoID ?? "mock_psicologo_123",
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
    
    /// Salva os dados do paciente e orquestra a limpeza/recriação da agenda se o status mudar.
    func salvar() {
        let pacienteAtualizado = obterPacienteAtualizado()
        
        patientRepository.atualizarPaciente(pacienteAtualizado)
        
        let statusAntigo = pacienteOriginal?.status ?? .ativo
        
        if statusAntigo != pacienteAtualizado.status {
            if pacienteAtualizado.status == .inativo {
                executarLimpezaDeAgenda(para: pacienteAtualizado.id)
            } else if pacienteAtualizado.status == .ativo {
                executarReativacaoDeAgenda(para: pacienteAtualizado)
            }
        }
    }
    
    private func executarLimpezaDeAgenda(para pacienteID: String) {
        let hoje = Calendar.current.startOfDay(for: Date())
        
        let sessoesFuturas = sessionRepository.fetchSessoes().filter {
            $0.pacienteID == pacienteID && $0.dataDaSessão >= hoje
        }
        
        for sessao in sessoesFuturas {
            sessionRepository.deletarSessao(id: sessao.id)
        }
    }
    
    private func executarReativacaoDeAgenda(para paciente: Patient) {
        let hoje = Calendar.current.startOfDay(for: Date())
        let dataFim = sessionGenerator.ultimoDiaDoProximoMes(aPartirDe: hoje)
        
        let regrasDoPaciente = fixedSessionRepository.fetchSessoesFixas().filter { $0.pacienteID == paciente.id }
        let todasSessoes = sessionRepository.fetchSessoes()
        
        for regra in regrasDoPaciente {
            let novasSessoes = sessionGenerator.gerarSessoes(para: regra, dataInicio: hoje, dataFim: dataFim)
            
            for novaSessao in novasSessoes {
                let jaExiste = todasSessoes.contains {
                    $0.sessaoFixaID == regra.id &&
                    Calendar.current.isDate($0.dataDaSessão, inSameDayAs: novaSessao.dataDaSessão) &&
                    $0.status != .cancelada
                }
                
                if !jaExiste {
                    sessionRepository.salvarSessao(novaSessao)
                }
            }
        }
    }
    
}
