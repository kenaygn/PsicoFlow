//
//  AddPatientView.swift
//  PsicoApp
//
//  Created by Kenay on 04/04/26.
//

import SwiftUI

struct AddPatientView: View {
    
    @Environment(\.dismiss) var dismiss

    @EnvironmentObject var authManager: AuthManager
    
    @StateObject private var viewModel = PatientFormViewModel()
    
    var onSave: (Patient) -> Void
    
    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Informações Pessoais")) {
                    TextField("Nome completo", text: $viewModel.nome).textInputAutocapitalization(.words)
                    TextField("E-mail", text: $viewModel.email).keyboardType(.emailAddress).autocorrectionDisabled().textInputAutocapitalization(.never)
                    TextField("Telefone (WhatsApp)", text: $viewModel.telefone).keyboardType(.phonePad)
                    TextField("Contato de Emergência (Opcional)", text: $viewModel.contatoEmergencia).keyboardType(.phonePad)
                }
                
                Section(header: Text("Sessão e Contrato")) {
                    Picker("Status do Paciente", selection: $viewModel.status) {
                        ForEach(PatientStatus.allCases, id: \.self) { statusItem in
                            Text(statusItem.rawValue).tag(statusItem)
                        }
                    }
                    HStack {
                        Text("R$").foregroundColor(.secondary)
                        TextField("Valor Mensal (Ex: 150,00)", text: $viewModel.valorTexto).keyboardType(.decimalPad)
                    }
                }
                
                Section(header: Text("Observações Iniciais"), footer: Text("Informações de triagem ou diagnóstico inicial.")) {
                    TextEditor(text: $viewModel.observacoes).frame(minHeight: 80)
                }
            }
            .navigationTitle("Novo Paciente")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancelar") { dismiss() }.foregroundColor(.red)
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Salvar") {
                        if let uid = authManager.userID {
                            let isPremium = authManager.currentUser?.premium ?? false
                            
                            Task {
                                let sucesso = await viewModel.salvar(userId: uid, isPremium: isPremium)
                                
                                if sucesso {
                                    let novoPaciente = viewModel.obterPacienteAtualizado(userId: uid)
                                    onSave(novoPaciente)
                                    dismiss()
                                }
                            }
                        }
                    }
                    .fontWeight(.bold)
                    .foregroundColor(viewModel.isFormValid ? .teal : .gray)
                    .disabled(!viewModel.isFormValid)
                }
            }
            .alert("Limite de Pacientes", isPresented: $viewModel.mostrarAlertaLimite) {
                Button("Entendi", role: .cancel) { }
            } message: {
                Text("Você atingiu o limite de 5 pacientes ativos do plano gratuito. Assine o Psyes Pro para adicionar novos pacientes.")
            }
        }
    }
}
