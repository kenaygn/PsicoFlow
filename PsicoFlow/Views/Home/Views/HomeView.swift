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
    
    @EnvironmentObject var router: AppRouter
    // 1. Injetamos o AuthManager para garantir a segurança dos dados
    @EnvironmentObject var authManager: AuthManager
    
    @StateObject private var viewModel = HomeViewModel()
    
    @State private var pacienteSelecionado: Patient? = nil
    @State private var navegarParaProntuario: Bool = false
    @State private var navegarParaDiaComConflito: Bool = false
    @State private var mostrarModalUpgrade: Bool = false
    
    @State private var slideAtual: HomeViewModel.HomeSlide = .proximaSessao
    let timer = Timer.publish(every: 7, on: .main, in: .common).autoconnect()
    
    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 24) {
                    
                    // MARK: - Destaque Principal (Carrossel)
                    TabView(selection: $slideAtual) {
                        ForEach(viewModel.slidesAtivos, id: \.self) { slide in
                            carregarSlide(slide)
                                .tag(slide)
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
                            title: viewModel.valoresPendentesText == "R$ 0" ? "Tudo certo" : "A Receber",
                            value: viewModel.valoresPendentesText,
                            icon: viewModel.valoresPendentesText == "R$ 0" ? "sparkles" : "exclamationmark.circle",
                            style: viewModel.valoresPendentesText == "R$ 0" ? .financeSuccess : .danger
                        )
                    }
                    
                    // MARK: - Agenda do Dia
                    HStack {
                        Text("Acontecendo Hoje")
                            .font(.title2.bold())
                        
                        Spacer()
                        
                        Button("Ver tudo") {
                            router.selectedTab = .agenda
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
                                    onSelectPaciente: {
                                        self.pacienteSelecionado = paciente
                                        self.navegarParaProntuario = true
                                    },
                                    onUpdateStatus: { novoStatus, novaData in
                                        // 2. Passando o userId para atualizar o status
                                        if let uid = authManager.usuarioID {
                                            viewModel.atualizarStatusDaSessao(sessaoID: sessao.id, novoStatus: novoStatus, novaData: novaData, userId: uid)
                                        }
                                    },
                                    fetchAvailableTimes: { dataDesejada, sessaoID in
                                        if let uid = authManager.usuarioID {
                                            return await viewModel.obterHorariosLivres(para: dataDesejada, ignorandoSessaoID: sessaoID, userId: uid)
                                        }
                                        
                                        
                                        return [] // Retorno temporário para não quebrar sua View atual
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
                .fullScreenCover(isPresented: $mostrarModalUpgrade) {
                    UpgradePlanView(limiteAtingido: viewModel.limitePlanoFreeAtingido)
                }
            }
            .onAppear {
                // 3. Carregamos os dados passando o userId logado
                if let uid = authManager.usuarioID {
                    viewModel.carregarDados(userId: uid)
                }
                
                viewModel.isUsuarioPremium = authManager.usuarioAtual?.premium ?? false
                
                if let primeiro = viewModel.slidesAtivos.first {
                    slideAtual = primeiro
                }
            }
            .onChange(of: authManager.usuarioAtual?.premium) { oldValue, newValue in
                viewModel.isUsuarioPremium = newValue ?? false
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


// MARK: - Subviews
extension HomeView {
    
    @ViewBuilder
    private func carregarSlide(_ slide: HomeViewModel.HomeSlide) -> some View {
        switch slide {
        case .conflito:
            if let dataDoProblema = viewModel.primeiraDataComConflito {
                ConflictAlertCard(dataDoConflito: dataDoProblema) {
                    router.goToAgendaConflict(day: dataDoProblema)
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
            
        case .pendencias:
            if let atraso = viewModel.primeiraPendenciaAtrasada {
                PaymentAlertCard(mesReferencia: viewModel.labelPendenciaFinanceira) {
                    router.goToFinancePendingMonth(month: atraso)
                }
                .padding(.horizontal, 20)
            }
        case .premium:
            PremiumHomeCard(limiteAtingido: viewModel.limitePlanoFreeAtingido) {
                mostrarModalUpgrade = true
            }
            .padding(.horizontal, 20)
        }
    }
}
