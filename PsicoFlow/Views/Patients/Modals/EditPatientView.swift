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
    @EnvironmentObject var authManager: AuthManager
    
    @Binding var pacienteAtual: Patient
    
    @StateObject private var viewModel: PatientFormViewModel
    
    @State private var mostrarAlertaExclusao = false
    @State private var textoConfirmacao = ""
    
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
                
                // MARK: - Zona de Risco (Exclusão)
                Section {
                    Button(action: {
                        mostrarAlertaExclusao = true
                    }) {
                        HStack {
                            Spacer()
                            if viewModel.estaExcluindo {
                                ProgressView()
                            } else {
                                Text("Excluir Definitivamente")
                                    .fontWeight(.bold)
                            }
                            Spacer()
                        }
                        .foregroundColor(viewModel.status == .ativo ? .gray : .red)
                    }
                    .disabled(viewModel.status == .ativo || viewModel.estaExcluindo)
                } footer: {
                    if viewModel.status == .ativo {
                        Text("Para excluir este paciente, você deve alterar o status para inativo primeiro.")
                    }
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
                        if let uid = authManager.usuarioID {
                            viewModel.salvar(userId: uid)
                            pacienteAtual = viewModel.obterPacienteAtualizado(userId: uid)
                            dismiss()
                        }
                    }
                    .fontWeight(.bold)
                    .foregroundColor(viewModel.isFormValid ? .teal : .gray)
                    .disabled(!viewModel.isFormValid)
                }
            }
            .alert("Ação Irreversível", isPresented: $mostrarAlertaExclusao) {
                
                TextField("Digite: \(viewModel.nome)", text: $textoConfirmacao)
                    .textInputAutocapitalization(.words) // Melhor para nomes
                    .autocorrectionDisabled() // Evita que o corretor altere o nome sem querer
                
                Button("Cancelar", role: .cancel) {
                    textoConfirmacao = ""
                }
                
                Button("Apagar Tudo", role: .destructive) {
                    if let uid = authManager.usuarioID {
                        Task {
                            let sucesso = await viewModel.excluirPaciente(userId: uid)
                            if sucesso {
                                dismiss() // Fecha a tela e volta para a lista se deu certo
                            }
                        }
                    }
                }
                // O botão só é habilitado se o texto digitado for exatamente igual ao nome do paciente
                .disabled(textoConfirmacao != viewModel.nome)
                
            } message: {
                // Mensagem personalizada com o nome do paciente!
                Text("Você está prestes a excluir todos os registros de \(viewModel.nome). Isso apagará para sempre todas as sessões, pagamentos e prontuários vinculados a este paciente.")
            }
        }
    }
}
