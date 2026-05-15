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
                    // Importante: Alerta visual para evitar que o usuário altere uma regra fixa sem querer
                    footer: Text(viewModel.isFixa ? "Alterar essas regras afetará as próximas sessões geradas para este paciente." : "Alterar esta sessão não afeta o contrato recorrente.")
                ) {
                    Picker("Modalidade", selection: $viewModel.selectedModalidade) {
                        Text("Presencial").tag(Modalidade.presencial)
                        Text("Online").tag(Modalidade.online)
                    }
                    
                    // Alterna o controle de entrada: Contratos dependem do dia da semana, sessões avulsas de uma data exata
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
                        ForEach(viewModel.horariosLivres, id: \.self) { horario in
                            Text(horario).tag(horario)
                        }
                    }
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
                    Button("Cancelar") { dismiss() }
                        .foregroundColor(.teal)
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Salvar") {
                        viewModel.salvarEdicao()
                        dismiss()
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
                    viewModel.deletarSessao()
                    dismiss()
                }
            } message: {
                Text(viewModel.isFixa
                     ? "Tem certeza? Isso apagará a regra e todas as sessões futuras vinculadas a ela. O histórico de sessões passadas será mantido."
                     : "Tem certeza que deseja excluir esta sessão avulsa permanentemente?")
            }
            
            // Recalcula a lista de horários livres sempre que a data ou o dia da semana mudam
            .onAppear {
                viewModel.atualizarSelecaoDeHorario()
            }
            .onChange(of: viewModel.selectedDate) { _ in
                viewModel.atualizarSelecaoDeHorario()
            }
            .onChange(of: viewModel.selectedWeekday) { _ in
                viewModel.atualizarSelecaoDeHorario()
            }
        }
    }
}
