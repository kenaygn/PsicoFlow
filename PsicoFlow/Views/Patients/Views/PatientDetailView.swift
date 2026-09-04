//
//  PatientDetailView.swift
//  PsicoFlow
//
//  Created by Kenay on 04/04/26.
//

import SwiftUI

/// Exibe o perfil completo do paciente e gerencia a navegação entre suas evoluções, finanças e sessões.
struct PatientDetailView: View {
    
    @EnvironmentObject var authManager: AuthManager
    @StateObject private var viewModel: PatientDetailViewModel
    
    @Environment(\.dismiss) var dismissDetalhes
    
    @State private var abaSelecionada = 0
    @State private var mostrarModalEdicao = false
    @State private var itemSessaoParaEditar: EditSessionItem? = nil
    @State private var mostrarNovoAgendamento = false
    
    init(paciente: Patient) {
        self._viewModel = StateObject(wrappedValue: PatientDetailViewModel(paciente: paciente))
    }
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 24) {
                
                // MARK: - Cabeçalho do Perfil
                VStack(spacing: 12) {
                    Text(viewModel.paciente.initials)
                        .font(.system(size: 32, weight: .bold))
                        .foregroundColor(Color(.darkGray))
                        .frame(width: 88, height: 88)
                        .background(Color(.systemGray6))
                        .clipShape(Circle())
                        .overlay(Circle().stroke(Color.white, lineWidth: 4))
                        .shadow(color: .black.opacity(0.05), radius: 8, y: 4)
                    
                    VStack(spacing: 4) {
                        Text(viewModel.paciente.name)
                            .font(.system(size: 24, weight: .bold))
                            .multilineTextAlignment(.center)
                        
                        Text(viewModel.paciente.status.rawValue.uppercased())
                            .font(.system(size: 11, weight: .bold))
                            .foregroundColor(viewModel.paciente.status == .active ? .green : .gray)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 4)
                            .background(viewModel.paciente.status == .active ? Color.green.opacity(0.1) : Color.gray.opacity(0.1))
                            .clipShape(Capsule())
                    }
                    
                    HStack(spacing: 16) {
                        CircleActionButton(icon: "phone.fill", color: .teal) { }
                        CircleActionButton(icon: "message.fill", color: .green) { }
                        CircleActionButton(icon: "envelope.fill", color: .blue) { }
                    }
                    .padding(.top, 8)
                }
                .padding(.top, 24)
                
                Picker("Abas", selection: $abaSelecionada) {
                    Text("Evolução").tag(0)
                    Text("Faturação").tag(1)
                    Text("Sessões").tag(2)
                }
                .pickerStyle(.segmented)
                .padding(.horizontal, 20)
                
                VStack {
                    if abaSelecionada == 0 {
                        EvolutionTabView(
                            evolucoes: viewModel.evolucoes,
                            adicionarEvolucao: { textoDigitado in
                                if let uid = authManager.usuarioID {
                                    viewModel.adicionarEvolucao(texto: textoDigitado, userId: uid)
                                }
                            },
                            atualizarEvolucao: { evolucaoAtualizada in
                                if let uid = authManager.usuarioID {
                                    viewModel.atualizarEvolucao(evolucaoAtualizada: evolucaoAtualizada, userId: uid)
                                }
                            },
                            deletarEvolucao: { idParaDeletar in
                                if let uid = authManager.usuarioID {
                                    viewModel.deletarEvolucao(id: idParaDeletar, userId: uid)
                                }
                            }
                        )
                    } else if abaSelecionada == 1 {
                        BillingTabView(
                            pagamentos: viewModel.pagamentos,
                            onTogglePagamento: { idPagamento in
                                if let uid = authManager.usuarioID {
                                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                        viewModel.togglePagamento(pagamentoID: idPagamento, userId: uid)
                                    }
                                }
                            }
                        )
                    } else if abaSelecionada == 2 {
                        SessionsTabView(
                            sessoesFixas: viewModel.sessoesFixas,
                            sessoesAvulsas: viewModel.sessoesAvulsasFuturas,
                            converterDia: { dia in viewModel.nomeDoDiaDaSemana(dia) },
                            onEditFixed: { fixa in self.itemSessaoParaEditar = .fixa(fixa) },
                            onEditAvulsa: { avulsa in self.itemSessaoParaEditar = .avulsa(avulsa) },
                            onAddFixed: { mostrarNovoAgendamento = true },
                            onAddAvulsa: { mostrarNovoAgendamento = true }
                        )
                    }
                }
            }
            .padding(.bottom, 40)
        }
        .onAppear {
            if let uid = authManager.usuarioID {
                viewModel.carregarDadosCompletos(userId: uid)
            }
        }
        .onTapGesture { esconderTeclado() }
        .background(Color(.systemGroupedBackground))
        .navigationTitle("Perfil Clínico")
        .navigationBarTitleDisplayMode(.inline)
        
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Editar") { mostrarModalEdicao = true }.fontWeight(.semibold).foregroundColor(.teal)
            }
        }
        .sheet(isPresented: $mostrarModalEdicao) {
            EditPatientView(
                pacienteAtual: $viewModel.paciente,
                fecharTelaAnterior: Binding(
                    get: { false },
                    set: { seDeveFechar in
                        if seDeveFechar { dismissDetalhes() }
                    }
                )
            )
            .onDisappear {
                if let uid = authManager.usuarioID { viewModel.carregarDadosCompletos(userId: uid) }
            }
        }
        .sheet(item: $itemSessaoParaEditar, onDismiss: {
            if let uid = authManager.usuarioID { viewModel.carregarDadosCompletos(userId: uid) }
        }) { itemParaEdit in
            EditSessionView(item: itemParaEdit, nomePaciente: viewModel.paciente.name)
        }
        .sheet(isPresented: $mostrarNovoAgendamento, onDismiss: {
            if let uid = authManager.usuarioID { viewModel.carregarDadosCompletos(userId: uid) }
        }) {
            NewSessionView()
        }
    }
}

// MARK: - Extensions

/// Oculta o teclado globalmente no app ao tocar fora dos campos de texto.
extension View {
    func esconderTeclado() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

#Preview {
    PatientDetailView(
        paciente: Patient(
            id: "p1",
            psychologistID: "user_dev_01",
            name: "Ana Carolina Silva",
            email: "ana@email.com",
            phobe: "(11) 98765-4321",
            status: .active,
            value: 150.0,
            createdAt: Date()
        )
    )
}
