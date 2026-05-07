//
//  PatientsView.swift
//  PsicoApp
//
//  Created by Kenay on 04/04/26.
//

import SwiftUI

/// Tela principal de listagem e busca de pacientes.
struct PatientsView: View {
    
    @StateObject private var viewModel = PatientsViewModel()
    @State private var mostrarModalAdicionar = false
    
    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 16) {
                    VStack(spacing: 12) {
                        
                        // Estado Vazio: Exibido quando a lista real está vazia ou a busca não acha ninguém
                        if viewModel.pacientesFiltrados.isEmpty {
                            VStack {
                                Image(systemName: "person.crop.circle.badge.questionmark")
                                    .font(.system(size: 40))
                                    .foregroundColor(Color(.systemGray4))
                                    .padding(.bottom, 8)
                                Text("Nenhum paciente encontrado.")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                            .padding(.top, 60)
                            
                        } else {
                            // Lista de Pacientes
                            ForEach(viewModel.pacientesFiltrados) { paciente in
                                NavigationLink(destination: PatientDetailView(paciente: paciente)) {
                                    PatientCardView(paciente: paciente)
                                }
                            }
                        }
                    }
                    // Importante: Espaçamento para garantir que o último item não fique escondido sob a TabBar
                    .padding(.bottom, 100)
                }
                .padding(.horizontal, 20)
            }
            .onAppear {
                // Garante que a lista esteja sempre atualizada ao voltar de outras telas
                viewModel.carregarPacientes()
            }
            .navigationTitle("Pacientes")
            .navigationBarTitleDisplayMode(.large)
            .searchable(text: $viewModel.searchText, placement: .navigationBarDrawer(displayMode: .always))
            .toolbar {
                ToolbarItem {
                    Button(action: { mostrarModalAdicionar.toggle() }) {
                        Image(systemName: "plus")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.teal)
                    }
                }
            }
            // Fluxo de criação de novo paciente
            .sheet(isPresented: $mostrarModalAdicionar) {
                AddPatientView { novoPaciente in
                    viewModel.adicionarPaciente(novoPaciente)
                }
            }
        }
    }
}

#Preview {
    PatientsView()
}
