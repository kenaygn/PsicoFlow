//
//  EditProfileView.swift
//  PsicoFlow
//
//  Created by Kenay on 08/06/26.
//

import SwiftUI

struct EditProfileView: View {
    @Environment(\.dismiss) var dismiss
    
    @StateObject private var viewModel: EditProfileViewModel
    
    init(authManager: AuthManager) {
        _viewModel = StateObject(
            wrappedValue: EditProfileViewModel(authManager: authManager)
        )
    }
    
    var body: some View {
        Form {
            // MARK: - Dados Profissionais
            Section(header: Text("Dados Profissionais")) {
                HStack {
                    Text("Nome")
                        .frame(width: 80, alignment: .leading)
                        .foregroundColor(.primary)
                    TextField("Seu nome completo", text: $viewModel.nome)
                        .textContentType(.name)
                }
                
                HStack {
                    Text("CRP")
                        .frame(width: 80, alignment: .leading)
                        .foregroundColor(.primary)
                    TextField("00/000000", text: $viewModel.crp)
                        .keyboardType(.numbersAndPunctuation)
                }
            }
            
            // MARK: - Horário de Expediente
            Section(
                header: Text("Horário de Expediente"),
                footer: Text("Defina o intervalo de horas que aparece na sua agenda diária.").foregroundColor(.secondary)
            ) {
                Picker("Início", selection: $viewModel.horaInicioExpediente) {
                    ForEach(viewModel.horariosDisponiveis, id: \.self) { horario in
                        Text(horario).tag(horario)
                    }
                }
                .onChange(of: viewModel.horaInicioExpediente) { _, novoInicio in
                    let inicioInt = Int(novoInicio.prefix(2)) ?? 0
                    let fimInt = Int(viewModel.horaFimExpediente.prefix(2)) ?? 0
                    
                    if inicioInt >= fimInt {
                        let novoFim = min(inicioInt + 1, 23) // Garante que não passe de 23:00
                        viewModel.horaFimExpediente = String(format: "%02d:00", novoFim)
                    }
                }
                
                Picker("Fim", selection: $viewModel.horaFimExpediente) {
                    ForEach(viewModel.horariosDisponiveis, id: \.self) { horario in
                        Text(horario).tag(horario)
                    }
                }
                .onChange(of: viewModel.horaFimExpediente) { _, novoFim in
                    let inicioInt = Int(viewModel.horaInicioExpediente.prefix(2)) ?? 0
                    let fimInt = Int(novoFim.prefix(2)) ?? 0
                    
                    if fimInt <= inicioInt {
                        let novoInicio = max(fimInt - 1, 0) // Garante que não seja menor que 00:00
                        viewModel.horaInicioExpediente = String(format: "%02d:00", novoInicio)
                    }
                }
            }
            
            // MARK: - Alteração de Senha (Condicional)
            if viewModel.isEmailProvider {
                Section(
                    header: Text("Alterar Senha"),
                    footer: Text("Deixe em branco caso não queira alterar sua senha atual.").foregroundColor(.secondary)
                ){
                    PasswordToggleField(
                        title: "Senha Atual",
                        text: $viewModel.senhaAtual,
                        contentType: .password
                    )
                    
                    PasswordToggleField(
                        title: "Nova Senha",
                        text: $viewModel.novaSenha,
                        contentType: .newPassword
                    )
                }
            } else {
                Section(header: Text("Autenticação")) {
                    Text("Sua conta está vinculada por meio de um provedor externo (Apple ou Google). A alteração de senha deve ser feita diretamente com o provedor correspondente.")
                        .font(.footnote)
                        .foregroundColor(.secondary)
                        .padding(.vertical, 4)
                }
            }
        }
        .navigationTitle("Editar Perfil")
        .navigationBarTitleDisplayMode(.inline)
        .scrollDismissesKeyboard(.interactively)
        
        // MARK: - Alerta de Erro
        .alert("Atenção", isPresented: Binding(
            get: { viewModel.errorMessage != nil },
            set: { if !$0 { viewModel.errorMessage = nil } }
        )) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(viewModel.errorMessage ?? "")
        }
        
        // MARK: - Toolbar
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Salvar") {
                    Task {
                        let sucesso = await viewModel.salvarAlteracoes()
                        if sucesso {
                            dismiss()
                        }
                    }
                }
                .fontWeight(.bold)
                .disabled(!viewModel.temAlteracoes || viewModel.isUpdating)
            }
        }
    }
}
