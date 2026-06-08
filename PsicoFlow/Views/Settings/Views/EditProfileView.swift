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
        _viewModel = StateObject(wrappedValue: EditProfileViewModel(authManager: authManager))
    }
    
    var body: some View {
        Form {
            Section(header: Text("Dados Profissionais")) {
                HStack {
                    Text("Nome")
                        .frame(width: 80, alignment: .leading)
                        .foregroundColor(.primary)
                    TextField("Seu nome completo", text: $viewModel.nome)
                        .textContentType(.name)
                }
                
                HStack {
                    Text("E-mail")
                        .frame(width: 80, alignment: .leading)
                        .foregroundColor(.primary)
                    TextField("Seu e-mail de acesso", text: $viewModel.email)
                        .keyboardType(.emailAddress)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled(true)
                }
                
                HStack {
                    Text("CRP")
                        .frame(width: 80, alignment: .leading)
                        .foregroundColor(.primary)
                    TextField("00/000000", text: $viewModel.crp)
                        .keyboardType(.numbersAndPunctuation)
                }
            }
            
            Section(
                header: Text("Alterar Senha"),
                footer:
                    Text(viewModel.senhasDivergem ? "As novas senhas não coincidem.\n" : "")
                    .foregroundColor(.red)
                + Text("Deixe em branco caso não queira alterar sua senha atual.")
                    .foregroundColor(.secondary)
            ){
                
                PasswordToggleField(title: "Senha Atual", text: $viewModel.senhaAtual, contentType: .password)
                
                PasswordToggleField(title: "Nova Senha", text: $viewModel.novaSenha, contentType: .newPassword)
                
                PasswordToggleField(title: "Confirmar Nova Senha", text: $viewModel.confirmarNovaSenha, contentType: .newPassword)
            }
        }
        .navigationTitle("Editar Perfil")
        .navigationBarTitleDisplayMode(.inline)
        .scrollDismissesKeyboard(.interactively)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Salvar") {
                    viewModel.salvarAlteracoes()
                    dismiss()
                }
                .fontWeight(.bold)
                .disabled(!viewModel.temAlteracoes)
            }
        }
    }
}

