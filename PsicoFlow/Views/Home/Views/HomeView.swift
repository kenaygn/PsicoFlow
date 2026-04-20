//
//  HomeView.swift
//  PsicoApp
//
//  Created by Kenay on 02/04/26.
//

import SwiftUI

struct HomeView: View {
    @StateObject private var viewModel = HomeViewModel()
    
    @State private var pacienteSelecionado: Patient? = nil
    @State private var navegarParaProntuario: Bool = false
    
    var body: some View {
        NavigationStack {
            ScrollView (showsIndicators: false) {
                VStack(spacing: 24) {
                    // Renderiza o card APENAS se a ViewModel achar uma próxima sessão baseada na hora atual
                    if let proxima = viewModel.proximaSessao {
                        NextSessionMainCard(
                            session: proxima,
                            nomeDaPaciente: viewModel.nomePacienteProximaSessao,
                            onAbrirProntuario: {
                                // Pegamos o paciente daquela sessão e acionamos o gatilho!
                                self.pacienteSelecionado = viewModel.paciente(for: proxima)
                                self.navegarParaProntuario = true
                            }
                        )
                        .padding(.top, 16)
                        
                    }else{
                        WeeklySummaryCard(atendimentosNaSemana: viewModel.atendimentosRealizadosNaSemana)
                    }
                    
                    HStack() {
                        // Card de Sessões
                        QuickStatCard(
                            title: "Sessões Hoje",
                            value: viewModel.totalSessoesHojeText, // Dado mastigado
                            icon: "calendar",
                            style: .primary
                        )
                        
                        Spacer()
                        
                        // Card Financeiro
                        QuickStatCard(
                            title: "A Receber",
                            value: viewModel.valoresPendentesText, // Dado mastigado
                            icon: "exclamationmark.circle",
                            style: .danger
                        )
                    }
                    
                    HStack(){
                        Text("Acontecendo Hoje")
                            .font(.title2.bold())
                        Spacer()
                        
                        Button("Ver tudo"){
                            print("Ir para tela de sessões")
                        }
                        .foregroundStyle(Color(.teal))
                        .font(.headline.bold())
                        
                    }
                    
                    
                    VStack(spacing: 16) {
                        if viewModel.sessoesHoje.isEmpty {
                            
                            // --- ESTADO VAZIO (EMPTY STATE) ---
                            VStack(spacing: 12) {
                                // Ícone de xícara de café ou sol, passando ideia de pausa/descanso
                                Image(systemName: "cup.and.saucer.fill")
                                    .font(.system(size: 40))
                                    .foregroundColor(.brown.opacity(0.6))
                                
                                Text("Livre hoje!")
                                    .font(.title3)
                                    .fontWeight(.bold)
                                    .foregroundColor(.brown)
                                
                                Text("Você não tem atendimentos pendentes. Aproveite para se organizar ou descansar.")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                    .multilineTextAlignment(.center)
                                    .padding(.horizontal, 20)
                            }
                            .padding(.vertical, 32)
                            .frame(maxWidth: .infinity)
                            .background(Color.white)
                            .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
                            .overlay(
                                RoundedRectangle(cornerRadius: 24, style: .continuous)
                                    .stroke(Color.gray.opacity(0.1), lineWidth: 1)
                            )
                            
                        } else {
                            
                            // --- LISTA DE SESSÕES ---
                            ForEach(viewModel.sessoesHoje) { sessao in
                                let paciente = viewModel.paciente(for: sessao)
                                let isNextSessao = (sessao.id == viewModel.proximaSessao?.id)
                                
                                TodaySessionCard(
                                    session: sessao,
                                    nomePaciente: paciente?.nome ?? "Paciente Deletado",
                                    iniciaisPaciente: paciente?.iniciais ?? "?",
                                    isNext: isNextSessao,
                                    onSelectPaciente: { self.navegarParaProntuario = true },
                                    onUpdateStatus: { novoStatus, novaData in
                                        viewModel.atualizarStatusDaSessao(sessaoID: sessao.id, novoStatus: novoStatus, novaData: novaData)
                                    },
                                    fetchAvailableTimes: { dataDesejada, sessaoID in
                                        viewModel.obterHorariosLivres(para: dataDesejada, ignorandoSessaoID: sessaoID)
                                    }
                                )
                            }
                        }
                    }
                    
                    
                    
                }
                .padding(.horizontal, 20)
                .alert(isPresented: $viewModel.mostrarAlertaConflito) {
                    Alert(
                        title: Text("Conflito de Horário"),
                        message: Text(viewModel.mensagemConflito),
                        dismissButton: .default(Text("Entendi"))
                    )
                }
                
            }
            .onAppear {
                viewModel.carregarDados()
            }
            .navigationTitle("Início")
            .navigationBarTitleDisplayMode(.automatic)
            .navigationDestination(isPresented: $navegarParaProntuario) {
                if let paciente = pacienteSelecionado {
                    // Abrimos a tela limpa e independente que criamos na etapa anterior!
                    PatientDetailView(paciente: paciente)
                }
            }
            
        }
    }
}

#Preview {
    HomeView()
}
