//
//  HomeAgendaSectionView.swift
//  PsicoFlow
//
//  Created by Kenay on 24/08/26.
//

import SwiftUI

struct HomeAgendaSectionView: View {
    @EnvironmentObject var router: AppRouter
    @EnvironmentObject var authManager: AuthManager
    @ObservedObject var viewModel: HomeViewModel
    
    @Binding var pacienteSelecionado: Patient?
    @Binding var navegarParaProntuario: Bool
    
    var body: some View {
        VStack(spacing: 24) {
            
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
                
                if !viewModel.carregamentoInicialConcluido {
                    Color.clear
                        .frame(height: 200)
                } else if viewModel.pacientes.isEmpty {
                    EmptyPatientsHomeCard {
                        router.selectedTab = .patients
                    }
                } else if viewModel.sessoesHoje.isEmpty {
                    estadoLivreHoje
                } else {
                    listaDeSessoesAtivas
                }
            }
        }
    }
    
    private var estadoLivreHoje: some View {
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
    }
    
    private var listaDeSessoesAtivas: some View {
        ForEach(viewModel.sessoesHoje) { sessao in
            let paciente = viewModel.paciente(for: sessao)
            let isNextSessao = (sessao.id == viewModel.proximaSessao?.id)
            
            TodaySessionCard(
                session: sessao,
                nomePaciente: paciente?.name ?? "Paciente Deletado",
                iniciaisPaciente: paciente?.initials ?? "?",
                isNext: isNextSessao,
                onSelectPaciente: {
                    self.pacienteSelecionado = paciente
                    self.navegarParaProntuario = true
                },
                onUpdateStatus: { novoStatus, novaData in
                    if let uid = authManager.userID {
                        viewModel.atualizarStatusDaSessao(sessaoID: sessao.id, novoStatus: novoStatus, novaData: novaData, userId: uid)
                    }
                },
                fetchAvailableTimes: { dataDesejada, sessaoID in
                    if let uid = authManager.userID {
                        return await viewModel.obterHorariosLivres(para: dataDesejada, ignorandoSessaoID: sessaoID, userId: uid)
                    }
                    return []
                }
            )
        }
    }
}
