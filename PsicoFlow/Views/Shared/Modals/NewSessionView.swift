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
    @EnvironmentObject var authManager: AuthManager
    
    init(dataSugerida: Date = Date(), horarioSugerido: String = "08:00") {
        _viewModel = StateObject(wrappedValue: NewSessionViewModel(
            dataSugerida: dataSugerida,
            horarioSugerido: horarioSugerido
        ))
    }
    
    var body: some View {
        NavigationStack {
            Form {
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
                
                Section(header: Text("Agendamento")) {
                    Toggle("Terapia Semanal (Fixa)", isOn: $viewModel.isFixedSession.animation())
                        .tint(.teal)
                    
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
                            Text("Buscando...").tag("")
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
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancelar") { dismiss() }.foregroundColor(.teal)
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Agendar") {
                        if let uid = authManager.usuarioID {
                            viewModel.salvarSessao(userId: uid)
                            dismiss()
                        }
                    }
                    .foregroundColor(.teal)
                    .disabled(viewModel.pacientesDisponiveis.isEmpty || viewModel.selectedTime.isEmpty)
                }
            }
            // Dispara as buscas assíncronas
            .onAppear {
                if let uid = authManager.usuarioID {
                    viewModel.carregarPacientes(userId: uid)
                    viewModel.carregarHorariosLivres(userId: uid)
                }
            }
            // Monitora alterações para atualizar horários do Firebase
            .onChange(of: viewModel.selectedDate) { _ in
                if let uid = authManager.usuarioID { viewModel.carregarHorariosLivres(userId: uid) }
            }
            .onChange(of: viewModel.selectedWeekday) { _ in
                if let uid = authManager.usuarioID { viewModel.carregarHorariosLivres(userId: uid) }
            }
            .onChange(of: viewModel.isFixedSession) { _ in
                if let uid = authManager.usuarioID { viewModel.carregarHorariosLivres(userId: uid) }
            }
        }
    }
}
