//
//  HomeView.swift
//  PsicoApp
//
//  Created by Kenay on 02/04/26.
//

import SwiftUI
import Combine

/// Tela principal do aplicativo (Dashboard).
/// Exibe o resumo financeiro e de agenda do dia, com atalhos dinâmicos para a próxima sessão.
struct HomeView: View {
    
    @StateObject private var viewModel = HomeViewModel()
    
    @State private var pacienteSelecionado: Patient? = nil
    @State private var navegarParaProntuario: Bool = false
    
    @State private var slideAtual: HomeViewModel.HomeSlide = .proximaSessao
    let timer = Timer.publish(every: 15, on: .main, in: .common).autoconnect()
    
    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 24) {
                    
                    // MARK: - Destaque Principal (Carrossel)
                    // O TabView permite o "swipe" horizontal entre os cartões
                    TabView(selection: $slideAtual) {
                        ForEach(viewModel.slidesAtivos, id: \.self) { slide in
                            switch slide {
                            case .conflito:
                                
                                if let dataDoProblema = viewModel.primeiraDataComConflito {
                                    ConflictAlertCard(dataDoConflito: dataDoProblema) {
                                        // TODO: Integrar navegação para a aba de Agenda futuramente
                                        print("Ir para a agenda resolver o conflito do dia \(dataDoProblema)")
                                    }
                                    .padding(.horizontal, 20)
                                }
                                
                            case .proximaSessao:
                                if let proxima = viewModel.proximaSessao {
                                    NextSessionMainCard(
                                        session: proxima,
                                        nomeDaPaciente: viewModel.nomePacienteProximaSessao,
                                        onAbrirProntuario: {
                                            self.pacienteSelecionado = viewModel.paciente(for: proxima)
                                            self.navegarParaProntuario = true
                                        }
                                    )
                                    .padding(.horizontal, 20)
                                }
                            case .resumo:
                                WeeklySummaryCard(atendimentosNaSemana: viewModel.atendimentosRealizadosNaSemana)
                                    .padding(.horizontal, 20)
                            }
                        }
                    }
                    .tabViewStyle(.page(indexDisplayMode: viewModel.slidesAtivos.count == 1 ? .never : .automatic))
                    .indexViewStyle(.page(backgroundDisplayMode: .always))
                    .frame(height: 208)
                    .padding(.vertical, -20)
                    .padding(.horizontal, -20)
                    
                    // MARK: - Métricas Rápidas
                    HStack {
                        QuickStatCard(
                            title: "Sessões Hoje",
                            value: viewModel.totalSessoesHojeText,
                            icon: "calendar",
                            style: .primary
                        )
                        
                        Spacer()
                        
                        QuickStatCard(
                            title: "A Receber",
                            value: viewModel.valoresPendentesText,
                            icon: "exclamationmark.circle",
                            style: .danger
                        )
                    }
                    
                    // MARK: - Agenda do Dia
                    HStack {
                        Text("Acontecendo Hoje")
                            .font(.title2.bold())
                        
                        Spacer()
                        
                        // TODO: Implementar fluxo para a tela completa do calendário/agenda geral
                        Button("Ver tudo") {
                            print("Ir para tela de sessões")
                        }
                        .foregroundStyle(Color(.teal))
                        .font(.headline.bold())
                    }
                    
                    VStack(spacing: 16) {
                        if viewModel.sessoesHoje.isEmpty {
                            
                            // Estado Vazio
                            VStack(spacing: 12) {
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
                            
                            // Lista de Sessões
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
                
                // MARK: - Alertas
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
                if let primeiro = viewModel.slidesAtivos.first {
                    slideAtual = primeiro
                }
            }
            .onReceive(timer) { _ in
                guard viewModel.slidesAtivos.count > 1 else { return }
                
                withAnimation(.easeInOut(duration: 0.6)) {
                    if let indiceAtual = viewModel.slidesAtivos.firstIndex(of: slideAtual) {
                        let proximoIndice = (indiceAtual + 1) % viewModel.slidesAtivos.count
                        slideAtual = viewModel.slidesAtivos[proximoIndice]
                    }
                }
            }
            .navigationTitle("Início")
            .navigationBarTitleDisplayMode(.automatic)
            
            // Note: A navegação ocorre de forma reativa ouvindo o estado `navegarParaProntuario`
            .navigationDestination(isPresented: $navegarParaProntuario) {
                if let paciente = pacienteSelecionado {
                    PatientDetailView(paciente: paciente)
                }
            }
        }
    }
}

#Preview {
    HomeView()
}
