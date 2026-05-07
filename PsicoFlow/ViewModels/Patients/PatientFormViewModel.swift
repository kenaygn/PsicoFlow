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
        
    init(paciente: Patient? = nil) {
        self.pacienteOriginal = paciente
        
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
}
