//
//  EditSessionView.swift
//  PsicoFlow
//
//  Created by Kenay on 05/05/26.
//

import SwiftUI

struct EditSessionView: View {
    @StateObject private var viewModel: EditSessionViewModel
    @Environment(\.dismiss) var dismiss
    
    init(item: EditSessionItem, nomePaciente: String) {
        _viewModel = StateObject(wrappedValue: EditSessionViewModel(item: item, nomePaciente: nomePaciente))
    }
    
    var body: some View {
        NavigationStack {
            Form {
                // --- PACIENTE ---
                Section(header: Text("Paciente")) {
                    HStack {
                        Text("Nome")
                        Spacer()
                        Text(viewModel.nomePaciente)
                            .foregroundColor(.secondary)
                    }
                }
                
                // --- DADOS DA SESSÃO ---
                Section(
                    header: Text(viewModel.isFixa ? "Regras do Contrato" : "Dados da Sessão"),
                    footer: Text(viewModel.isFixa ? "Alterar essas regras afetará as próximas sessões geradas para este paciente." : "Alterar esta sessão não afeta o contrato recorrente.")
                ) {
                    Picker("Modalidade", selection: $viewModel.selectedModalidade) {
                        Text("Presencial").tag(Modalidade.presencial)
                        Text("Online").tag(Modalidade.online)
                    }
                    
                    // 👇 A Mágica Visual: Muda o componente conforme o tipo!
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
