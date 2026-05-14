//
//  NewSessionView.swift
//  PsicoFlow
//
//  Created by Kenay on 13/04/26.
//

import SwiftUI

/// Formulário de agendamento que permite a criação de sessões avulsas ou contratos recorrentes.
struct NewSessionView: View {
    
    @StateObject private var viewModel: NewSessionViewModel
    @Environment(\.dismiss) var dismiss
    
    init(dataSugerida: Date = Date(), horarioSugerido: String = "08:00") {
        _viewModel = StateObject(wrappedValue: NewSessionViewModel(
            dataSugerida: dataSugerida,
            horarioSugerido: horarioSugerido
        ))
    }
    
    var body: some View {
        NavigationStack {
            Form {
                
                // MARK: - Seleção de Paciente
                Section(header: Text("Informações do Paciente")) {
                    if viewModel.pacientesDisponiveis.isEmpty {
                        Text("Nenhum paciente ativo cadastrado.")
                            .foregroundColor(.secondary)
                    } else {
                        Picker("Paciente", selection: $viewModel.pacienteSelecionadoID) {
                            ForEach(viewModel.pacientesDisponiveis) { paciente in
                                Text(paciente.nome).tag(paciente.id)
                            }
                        }
                        
                        Picker("Modalidade", selection: $viewModel.selectedModalidade) {
                            Text("Presencial").tag(Modalidade.presencial)
                            Text("Online").tag(Modalidade.online)
                        }
                    }
                }
                
                // MARK: - Configuração de Horário
                Section(
                    header: Text("Agendamento"),
                    footer: Text(viewModel.isFixedSession ? "Cria as sessões automaticamente toda semana neste mesmo dia e horário." : "Cria apenas um evento único no calendário.")
                ) {
                    
                    Toggle("Terapia Semanal (Fixa)", isOn: $viewModel.isFixedSession.animation())
                        .tint(.teal)
                    
                    // Note: A alternância entre Picker de semana e DatePicker garante a integridade dos dados
                    // dependendo se a sessão é um contrato (Fixed) ou um evento único (Single).
                    if viewModel.isFixedSession {
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
                            Text("Agenda Lotada").tag("")
                        } else {
                            ForEach(viewModel.horariosLivres, id: \.self) { horario in
                                Text(horario).tag(horario)
                            }
                        }
                    }
                    .disabled(viewModel.horariosLivres.isEmpty)
                }
            }
            .navigationTitle("Agendamento")
            .navigationBarTitleDisplayMode(.inline)
            
            // MARK: - Toolbar
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancelar") {
                        dismiss()
                    }
                    .foregroundColor(.teal)
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Agendar") {
                        viewModel.salvarSessao()
                        dismiss()
                    }
                    .foregroundColor(.teal)
                    .disabled(viewModel.pacientesDisponiveis.isEmpty)
                }
            }
            
            // MARK: - Reatividade
            // Recalcula a disponibilidade da agenda sempre que houver alteração nos parâmetros de tempo.
            .onAppear {
                viewModel.atualizarSelecaoDeHorario()
            }
            .onChange(of: viewModel.selectedDate) { _ in
                viewModel.atualizarSelecaoDeHorario()
            }
            .onChange(of: viewModel.selectedWeekday) { _ in
                viewModel.atualizarSelecaoDeHorario()
            }
            .onChange(of: viewModel.isFixedSession) { _ in
                viewModel.atualizarSelecaoDeHorario()
            }
        }
    }
}

#Preview {
    NewSessionView()
}
