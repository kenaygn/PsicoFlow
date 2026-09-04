//
//  EditSessionView.swift
//  PsicoFlow
//
//  Created by Kenay on 05/05/26.
//

import SwiftUI

/// Modal de edição que adapta dinamicamente sua interface dependendo
/// se o usuário está alterando uma sessão avulsa ou um contrato de recorrência (fixa).
struct EditSessionView: View {
    
    @StateObject private var viewModel: PatientEditSessionViewModel
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var authManager: AuthManager
    
    @State private var mostrarAlertaExclusao = false
    
    init(item: EditSessionItem, nomePaciente: String) {
        _viewModel = StateObject(wrappedValue: PatientEditSessionViewModel(item: item, nomePaciente: nomePaciente))
    }
    
    var body: some View {
        NavigationStack {
            Form {
                
                // MARK: - Informações do Paciente
                Section(header: Text("Paciente")) {
                    HStack {
                        Text("Nome")
                        Spacer()
                        Text(viewModel.nomePaciente)
                            .foregroundColor(.secondary)
                    }
                }
                
                // MARK: - Dados da Sessão
                Section(
                    header: Text(viewModel.isFixa ? "Regras do Contrato" : "Dados da Sessão"),
                    footer: Text(viewModel.isFixa ? "Alterar essas regras afetará as próximas sessões geradas para este paciente." : "Alterar esta sessão não afeta o contrato recorrente.")
                ) {
                    Picker("Modalidade", selection: $viewModel.selectedModalidade) {
                        Text("Presencial").tag(Modality.inPerson)
                        Text("Online").tag(Modality.online)
                    }
                    
                    if viewModel.isFixa {
                        Picker("Dia da Semana", selection: $viewModel.selectedWeekday) {
                            Text("Domingo").tag(1)
                            Text("Segunda-feira").tag(2)
                            Text("Terça-feira").tag(3)
                            Text("Quarta-feira").tag(4)
                            Text("Quinta-feira").tag(5)
                            Text("Sexta-feira").tag(6)
                            Text("Sábado").tag(7)
                        }
                    } else {
                        DatePicker("Data da Sessão", selection: $viewModel.selectedDate, displayedComponents: .date)
                            .environment(\.locale, Locale(identifier: "pt_BR"))
                    }
                    
                    Picker("Horário", selection: $viewModel.selectedTime) {
                        if viewModel.horariosLivres.isEmpty {
                            Text("Buscando...").tag("")
                        } else {
                            ForEach(viewModel.horariosLivres, id: \.self) { horario in
                                Text(horario).tag(horario)
                            }
                        }
                    }
                    .disabled(viewModel.horariosLivres.isEmpty)
                }
                
                // MARK: - Zona de Perigo (Exclusão)
                Section {
                    Button(role: .destructive) {
                        mostrarAlertaExclusao = true
                    } label: {
                        HStack {
                            Spacer()
                            Text(viewModel.isFixa ? "Excluir Contrato Recorrente" : "Excluir Sessão")
                                .fontWeight(.semibold)
                            Spacer()
                        }
                    }
                }
            }
            .navigationTitle(viewModel.isFixa ? "Sessão Semanal" : "Editar Sessão")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancelar") { dismiss() }.foregroundColor(.teal)
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Salvar") {
                        if let uid = authManager.userID {
                            viewModel.salvarEdicao(userId: uid)
                            dismiss()
                        }
                    }
                    .foregroundColor(.teal)
                }
            }
            
            // MARK: - Alerta de Confirmação
            .alert(
                viewModel.isFixa ? "Excluir Contrato?" : "Excluir Sessão?",
                isPresented: $mostrarAlertaExclusao
            ) {
                Button("Cancelar", role: .cancel) { }
                Button("Excluir", role: .destructive) {
                    if let uid = authManager.userID {
                        viewModel.deletarSessao(userId: uid)
                        dismiss()
                    }
                }
            } message: {
                Text(viewModel.isFixa
                     ? "Tem certeza? Isso apagará a regra e todas as sessões futuras vinculadas a ela. O histórico de sessões passadas será mantido."
                     : "Tem certeza que deseja excluir esta sessão avulsa permanentemente?")
            }
            
            // Carregamento inicial e reatividade via Firebase
            .onAppear {
                if let uid = authManager.userID {
                    viewModel.carregarHorariosLivres(userId: uid)
                }
            }
            .onChange(of: viewModel.selectedDate) { _ in
                if let uid = authManager.userID { viewModel.carregarHorariosLivres(userId: uid) }
            }
            .onChange(of: viewModel.selectedWeekday) { _ in
                if let uid = authManager.userID { viewModel.carregarHorariosLivres(userId: uid) }
            }
        }
    }
}
