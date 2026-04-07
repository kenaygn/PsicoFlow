//
//  PatientsView.swift
//  PsicoApp
//
//  Created by Kenay on 04/04/26.
//

import SwiftUI


struct PatientsView: View {
    @StateObject private var viewModel = PatientsViewModel()
    
    
    @State private var mostrarModalAdicionar = false
    
    var body: some View {
        NavigationStack{
            ScrollView(showsIndicators: false){
                VStack(spacing: 16) {
                    // --- LISTA DE PACIENTES ---
                    VStack(spacing: 12) {
                        
                        // Estado Vazio: Quando a busca não encontra ninguém
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
                            // Lista renderizada com animação suave de reordenação
                            ForEach(viewModel.pacientesFiltrados) { paciente in
                                
                                NavigationLink(destination: PatientDetailView(paciente: paciente)) {
                                    PatientCardView(paciente: paciente)
                                }
                                
                            }
                        }
                    }
                    .padding(.bottom, 100)
                    
                    
                }
                .padding(.horizontal, 20)
                
            }
            .onAppear {
                        viewModel.carregarPacientes()
                    }
            .navigationTitle("Pacientes")
            .navigationBarTitleDisplayMode(.large)
            .searchable(text: $viewModel.searchText, placement: .navigationBarDrawer(displayMode: .always), )
            
            // Botão de "+" no topo para adicionar novo paciente
            .toolbar {
                ToolbarItem() {
                    Button(action: { mostrarModalAdicionar.toggle()}) {
                        Image(systemName: "plus")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.teal)
                    }
                }
            }
            
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
