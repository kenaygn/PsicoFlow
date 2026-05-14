//
//  EditPatientView.swift
//  PsicoFlow
//
//  Created by Kenay on 04/04/26.
//

import SwiftUI

/// Formulário de edição de dados cadastrais.
/// Sincroniza as alterações diretamente com a View pai através do Binding `pacienteAtual`.
struct EditPatientView: View {
    
    @Environment(\.dismiss) var dismiss
    @Binding var pacienteAtual: Patient
    
    @StateObject private var viewModel: PatientFormViewModel
    
    init(pacienteAtual: Binding<Patient>) {
        self._pacienteAtual = pacienteAtual
        self._viewModel = StateObject(wrappedValue: PatientFormViewModel(paciente: pacienteAtual.wrappedValue))
    }
    
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
            .navigationTitle("Editar Paciente")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancelar") { dismiss() }
                        .foregroundColor(.red)
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Salvar") {
                        viewModel.salvar()
                        pacienteAtual = viewModel.obterPacienteAtualizado()
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
