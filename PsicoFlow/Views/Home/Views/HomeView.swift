//
//  HomeView.swift
//  PsicoApp
//
//  Created by Kenay on 02/04/26.
//

import SwiftUI
import Combine

struct HomeView: View {
    @EnvironmentObject var router: AppRouter
    @EnvironmentObject var authManager: AuthManager
    
    @StateObject private var viewModel = HomeViewModel()
    
    @State private var pacienteSelecionado: Patient? = nil
    @State private var navegarParaProntuario: Bool = false
    @State private var mostrarModalUpgrade: Bool = false
    
    @State private var slideAtual: HomeViewModel.HomeSlide = .proximaSessao
    let timer = Timer.publish(every: 7, on: .main, in: .common).autoconnect()
    
    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 24) {
                    
                    HomeCarouselView(
                        viewModel: viewModel,
                        slideAtual: $slideAtual,
                        pacienteSelecionado: $pacienteSelecionado,
                        navegarParaProntuario: $navegarParaProntuario,
                        mostrarModalUpgrade: $mostrarModalUpgrade
                    )
                    
                    HomeMetricsView(viewModel: viewModel)
                    
                    HomeAgendaSectionView(
                        viewModel: viewModel,
                        pacienteSelecionado: $pacienteSelecionado,
                        navegarParaProntuario: $navegarParaProntuario
                    )
                    
                }
                .padding(.horizontal, 20)
                
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
                if let uid = authManager.usuarioID {
                    viewModel.carregarDados(userId: uid)
                }
                viewModel.isUsuarioPremium = authManager.usuarioAtual?.premium ?? false
                if let primeiro = viewModel.slidesAtivos.first {
                    slideAtual = primeiro
                }
            }
            .onChange(of: authManager.usuarioAtual?.premium) { _, newValue in
                viewModel.isUsuarioPremium = newValue ?? false
            }
            .onChange(of: viewModel.slidesAtivos) { _, novosSlides in
                if !novosSlides.contains(slideAtual) {
                    if let primeiro = novosSlides.first {
                        slideAtual = primeiro
                    }
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
            .navigationDestination(isPresented: $navegarParaProntuario) {
                if let paciente = pacienteSelecionado {
                    PatientDetailView(paciente: paciente)
                }
            }
        }
    }
}
