//
//  NewSessionView.swift
//  PsicoFlow
//
//  Created by Kenay on 13/04/26.
//

import SwiftUI

struct NewSessionView: View {
    @StateObject private var viewModel: NewSessionViewModel
    @Environment(\.dismiss) var dismiss
    
    init(dataSugerida: Date = Date(), horarioSugerido: String = "08:00") {
        // Inicializa o StateObject passando as sugestões
        _viewModel = StateObject(wrappedValue: NewSessionViewModel(
            dataSugerida: dataSugerida, 
            horarioSugerido: horarioSugerido
        ))
    }
    
    var body: some View {
        NavigationStack {
            Form {
                
                // --- SEÇÃO 1: PACIENTE ---
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
                
                // --- SEÇÃO 2: TIPO DE AGENDAMENTO ---
                Section(header: Text("Agendamento"), footer: Text(viewModel.isFixedSession ? "Cria as sessões automaticamente toda semana neste mesmo dia e horário." : "Cria apenas um evento único no calendário.")) {
                    
                    Toggle("Terapia Semanal (Fixa)", isOn: $viewModel.isFixedSession.animation())
                        .tint(.teal)
                    
                    if viewModel.isFixedSession {
                        // Mostra seletor de DIA DA SEMANA
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
                        // Mostra seletor de DATA EXATA
                        DatePicker("Data da Sessão", selection: $viewModel.selectedDate, displayedComponents: .date)
                            .environment(\.locale, Locale(identifier: "pt_BR"))
                    }
                    
                    
                    // Picker Inteligente de Horário
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
            .toolbar {
                // Lado Esquerdo (Cancelar)
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancelar") {
                        dismiss()
                    }
                    .foregroundColor(.teal)
                }
                
                // Lado Direito (Ação Principal)
                ToolbarItem(placement: .confirmationAction) {
                    Button("Agendar"){
                        viewModel.salvarSessao()
                        dismiss()
                    }
                    .foregroundColor(.teal)
                    // Desativa o botão se não houver paciente para salvar
                    .disabled(viewModel.pacientesDisponiveis.isEmpty)
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
            .onChange(of: viewModel.isFixedSession) { _ in
                viewModel.atualizarSelecaoDeHorario()
            }
        }
    }
}

#Preview {
    NewSessionView()
}
