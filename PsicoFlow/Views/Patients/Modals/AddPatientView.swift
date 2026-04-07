//
//  AddPatientView.swift
//  PsicoApp
//
//  Created by Kenay on 04/04/26.
//

import SwiftUI

struct AddPatientView: View {
    @Environment(\.dismiss) var dismiss
    
    // 1. Instanciamos a nossa ViewModel descartável
    @StateObject private var viewModel = PatientFormViewModel()
    
    var onSave: (Patient) -> Void
    
    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Informações Pessoais")) {
                    // Trocamos os $nome soltos por $viewModel.nome
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
                
                Section(header: Text("Observações Iniciais"), footer: Text("Informações de triagem ou diagnóstico inicial.")) {
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
                        // 2. Pedimos o paciente pronto para a ViewModel e passamos para cima!
                        let novoPaciente = viewModel.obterPacienteAtualizado()
                        onSave(novoPaciente)
                        dismiss()
                    }
                    .fontWeight(.bold)
                    // 3. A View só pergunta para a ViewModel se está tudo válido
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
