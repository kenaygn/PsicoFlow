//
//  AddPatientView.swift
//  PsicoApp
//
//  Created by Kenay on 04/04/26.
//

import SwiftUI

/// Formulário para cadastro de um novo paciente.
/// Utiliza a closure `onSave` para delegar a responsabilidade de persistência à View pai.
struct AddPatientView: View {
    
    @Environment(\.dismiss) var dismiss
    @StateObject private var viewModel = PatientFormViewModel()
    
    var onSave: (Patient) -> Void
    
    var body: some View {
        NavigationStack {
            Form {
                
                // MARK: - Informações Pessoais
                Section(header: Text("Informações Pessoais")) {
                    TextField("Nome completo", text: $viewModel.nome)
                        .textInputAutocapitalization(.words)
                    
                    TextField("E-mail", text: $viewModel.email)
                        .keyboardType(.emailAddress)
                        .autocorrectionDisabled()
                        .textInputAutocapitalization(.never)
                    
                    TextField("Telefone (WhatsApp)", text: $viewModel.telefone)
                        .keyboardType(.phonePad)
                    
                    TextField("Contato de Emergência (Opcional)", text: $viewModel.contatoEmergencia)
                        .keyboardType(.phonePad)
                }
                
                // MARK: - Sessão e Contrato
                Section(header: Text("Sessão e Contrato")) {
                    Picker("Status do Paciente", selection: $viewModel.status) {
                        ForEach(PatientStatus.allCases, id: \.self) { statusItem in
                            Text(statusItem.rawValue).tag(statusItem)
                        }
                    }
                    
                    HStack {
                        Text("R$").foregroundColor(.secondary)
                        TextField("Valor Mensal (Ex: 150,00)", text: $viewModel.valorTexto)
                            .keyboardType(.decimalPad)
                    }
                }
                
                // MARK: - Observações
                Section(
                    header: Text("Observações Iniciais"),
                    footer: Text("Informações de triagem ou diagnóstico inicial.")
                ) {
                    TextEditor(text: $viewModel.observacoes)
                        .frame(minHeight: 80)
                }
            }
            .navigationTitle("Novo Paciente")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancelar") { dismiss() }
                        .foregroundColor(.red)
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Salvar") {
                        let novoPaciente = viewModel.obterPacienteAtualizado()
                        onSave(novoPaciente)
                        dismiss()
                    }
                    .fontWeight(.bold)
                    .foregroundColor(viewModel.isFormValid ? .teal : .gray)
                    .disabled(!viewModel.isFormValid)
                }
            }
        }
    }
}

#Preview {
    AddPatientView { paciente in
        print("Paciente salvo: \(paciente.nome)")
    }
}
