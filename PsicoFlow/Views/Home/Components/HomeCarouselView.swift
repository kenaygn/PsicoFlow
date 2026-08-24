//
//  HomeCarouselView.swift
//  PsicoFlow
//
//  Created by Kenay on 24/08/26.
//

import SwiftUI

struct HomeCarouselView: View {
    @EnvironmentObject var router: AppRouter
    @ObservedObject var viewModel: HomeViewModel
    
    @Binding var slideAtual: HomeViewModel.HomeSlide
    @Binding var pacienteSelecionado: Patient?
    @Binding var navegarParaProntuario: Bool
    @Binding var mostrarModalUpgrade: Bool
    
    var body: some View {
        TabView(selection: $slideAtual) {
            ForEach(viewModel.slidesAtivos, id: \.self) { slide in
                carregarSlide(slide)
                    .tag(slide)
            }
        }
        .tabViewStyle(.page(indexDisplayMode: viewModel.slidesAtivos.count == 1 ? .never : .automatic))
        .indexViewStyle(.page(backgroundDisplayMode: .always))
        .id(viewModel.slidesAtivos.count)
        .frame(height: 208)
        .padding(.vertical, -20)
        .padding(.horizontal, -20)
    }
    
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
