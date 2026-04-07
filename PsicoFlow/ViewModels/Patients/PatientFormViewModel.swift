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
    
    // Guardamos o paciente original para não perder o ID nem a data de criação na hora de salvar
    private var pacienteOriginal: Patient?
    
    // 👇 O SEGREDO DA REUTILIZAÇÃO:
    // Se passarmos um paciente, ele preenche os dados. Se não passarmos, ele cria vazio!
    init(paciente: Patient? = nil) {
        self.pacienteOriginal = paciente
        
        if let paciente = paciente {
            self.nome = paciente.nome
            self.email = paciente.email
            self.telefone = paciente.telefone
            self.contatoEmergencia = paciente.contatoEmergencia ?? ""
            self.status = paciente.status
            self.observacoes = paciente.observacoes ?? ""
            
            // Formata o Double de volta para texto (ex: 150.0 -> "150,00")
            let valorString = String(format: "%.2f", paciente.valor).replacingOccurrences(of: ".", with: ",")
            self.valorTexto = valorString
        }
    }
    
    var isFormValid: Bool {
        let nomePreenchido = !nome.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        let valorValido = Double(valorTexto.replacingOccurrences(of: ",", with: ".")) != nil
        return nomePreenchido && valorValido
    }
    
    // Essa função agora serve tanto para criar um novo quanto para devolver o editado
    func obterPacienteAtualizado() -> Patient {
        let valorConvertido = Double(valorTexto.replacingOccurrences(of: ",", with: ".")) ?? 0.0
        
        return Patient(
            // Mantém o ID original se for edição, ou cria um novo se for adição
            id: pacienteOriginal?.id ?? UUID().uuidString,
            psicologoID: pacienteOriginal?.psicologoID ?? "mock_psicologo_123",
            nome: nome,
            email: email,
            telefone: telefone,
            contatoEmergencia: contatoEmergencia.isEmpty ? nil : contatoEmergencia,
            observacoes: observacoes.isEmpty ? nil : observacoes,
            status: status,
            valor: valorConvertido,
            // Mantém a data original se for edição, ou pega a data de hoje se for novo
            criadoEm: pacienteOriginal?.criadoEm ?? Date()
        )
    }
}
