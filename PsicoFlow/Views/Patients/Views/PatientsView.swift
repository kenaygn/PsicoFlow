//
//  PatientsView.swift
//  PsicoApp
//
//  Created by Kenay on 04/04/26.
//

import SwiftUI

/// Tela principal de listagem e busca de pacientes.
struct PatientsView: View {
    
    // 1. Injetamos o gerenciador de autenticação
    @EnvironmentObject var authManager: AuthManager
    
    @StateObject private var viewModel = PatientsViewModel()
    @State private var mostrarModalAdicionar = false
    @State private var mostrarModalUpgrade = false
    
    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 16) {
                    VStack(spacing: 12) {
                        
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
                // 2. Passamos o ID do usuário logado para carregar a lista correta
                if let uid = authManager.usuarioID {
                    viewModel.carregarPacientes(userId: uid)
                }
            }
            .navigationTitle("Pacientes")
            .navigationBarTitleDisplayMode(.large)
            .searchable(text: $viewModel.searchText, placement: .navigationBarDrawer(displayMode: .always))
            .toolbar {
                ToolbarItem {
                    Button(action: {
                        
                        let isPremium = authManager.usuarioAtual?.premium ?? false
                        
                        if viewModel.limitePlanoFreeAtingido && !isPremium {
                            mostrarModalUpgrade = true
                        } else {
                            mostrarModalAdicionar = true
                        }
                    }) {
                        Image(systemName: "plus")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.teal)
                    }
                }
            }
            .sheet(isPresented: $mostrarModalAdicionar) {
                AddPatientView { novoPaciente in
                    // 3. Passamos o ID do usuário ao salvar um novo paciente
                    if let uid = authManager.usuarioID {
                        viewModel.adicionarPaciente(novoPaciente, userId: uid)
                    }
                }
            }
            .onChange(of: viewModel.pacientes.count) { oldValue, newValue in
                let isPremium = authManager.usuarioAtual?.premium ?? false
                
                if oldValue == 4 && newValue == 5 && !isPremium {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                        mostrarModalUpgrade = true
                    }
                }
            }
            .fullScreenCover(isPresented: $mostrarModalUpgrade) {
                UpgradePlanView(limiteAtingido: true)
            }
        }
    }
}

