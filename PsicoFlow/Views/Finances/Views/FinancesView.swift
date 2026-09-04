//
//  FinancesView.swift
//  PsicoFlow
//
//  Created by Kenay on 07/04/26.
//

import SwiftUI

/// Tela principal de gestão financeira do psicólogo.
/// Exibe o resumo de recebimentos e pendências, permitindo alternar entre visões mensais e anuais.
struct FinancesView: View {
    
    @EnvironmentObject var router: AppRouter
    @EnvironmentObject var authManager: AuthManager
    
    @StateObject private var viewModel = FinanceViewModel()
    
    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 24) {
                    
                    // MARK: - Cards Sections
                    if let dataAtraso = viewModel.dataDaPrimeiraPendenciaAtrasada {
                        PaymentAlertCard(mesReferencia: viewModel.labelPrimeiraPendencia) {
                            withAnimation {
                                viewModel.currentDate = dataAtraso
                                viewModel.viewMode = .mensal
                            }
                        }
                    } else {
                        FinancesSuccessCard()
                    }
                    
                    // MARK: - Filtro de Visualização
                    Picker("Modo de Visualização", selection: $viewModel.viewMode) {
                        Text("Mensal").tag(FinanceViewMode.mensal)
                        Text("Anual").tag(FinanceViewMode.anual)
                    }
                    .pickerStyle(.segmented)
                    .padding(.top, 8)
                    
                    // MARK: - Navegação de Período
                    HStack {
                        Text(viewModel.labelPeriodo)
                            .font(.system(size: 22, weight: .bold))
                            .foregroundColor(Color(.darkText))
                        
                        Spacer()
                        
                        HStack(spacing: 12) {
                            Button(action: {
                                withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                                    viewModel.irParaPeriodoAtual()
                                }
                            }) {
                                Text(viewModel.viewMode == .mensal ? "Mês Atual" : "Ano Atual")
                                    .font(.system(size: 13, weight: .bold))
                                    .foregroundColor(viewModel.isPeriodoAtual ? Color(.gray) : Color(.teal))
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 6)
                                    .background(viewModel.isPeriodoAtual ? Color(.systemGray6) : Color.teal.opacity(0.15))
                                    .clipShape(Capsule())
                            }
                            .disabled(viewModel.isPeriodoAtual)
                            
                            HStack(spacing: 8) {
                                Button(action: {
                                    withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                                        viewModel.voltarPeriodo()
                                    }
                                }) {
                                    Image(systemName: "chevron.left")
                                        .font(.system(size: 14, weight: .bold))
                                        .foregroundColor(.gray)
                                        .frame(width: 32, height: 32)
                                        .background(Color(.systemGray6))
                                        .clipShape(Circle())
                                }
                                
                                Button(action: {
                                    withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                                        viewModel.avancarPeriodo()
                                    }
                                }) {
                                    Image(systemName: "chevron.right")
                                        .font(.system(size: 14, weight: .bold))
                                        .foregroundColor(.gray)
                                        .frame(width: 32, height: 32)
                                        .background(Color(.systemGray6))
                                        .clipShape(Circle())
                                }
                            }
                        }
                    }
                    
                    // MARK: - Resumo Financeiro
                    HStack(spacing: 16) {
                        FinanceStatCard(
                            titulo: "Recebido",
                            valor: viewModel.totalRecebidoText,
                            icone: "checkmark.circle.fill",
                            corTema: .teal
                        )
                        
                        FinanceStatCard(
                            titulo: viewModel.totalPendenteText == "R$ 0" ? "Tudo Certo" : "A Receber",
                            valor: viewModel.totalPendenteText,
                            icone: viewModel.totalPendenteText == "R$ 0" ? "sparkles" : "exclamationmark.circle.fill",
                            corTema: viewModel.totalPendenteText == "R$ 0" ? .green : .red
                        )
                    }
                    
                    // MARK: - Pagamentos Pendentes
                    VStack(alignment: .leading, spacing: 16) {
                        HStack(spacing: 8) {
                            Circle().fill(Color.red).frame(width: 8, height: 8)
                            Text("Falta Pagar")
                                .font(.title3.bold())
                        }
                        
                        if viewModel.pagamentosPendentes.isEmpty {
                            Text("Nenhuma pendência neste período.")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                                .frame(maxWidth: .infinity, alignment: .center)
                                .padding()
                                .background(Color.white)
                                .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                                .padding(.horizontal, 20)
                        } else {
                            ForEach(viewModel.pagamentosPendentes) { pagamento in
                                let paciente = viewModel.paciente(for: pagamento)
                                PendingPaymentCard(
                                    pagamento: pagamento,
                                    nomePaciente: paciente?.name ?? "Desconhecido",
                                    iniciais: paciente?.initials ?? "?",
                                    mesFormatado: viewModel.formatarMesRefParaExibicao(pagamento.mesReferencia),
                                    onPagar: {
                                        // 2. Repassamos o ID do usuário para o ViewModel
                                        if let uid = authManager.usuarioID {
                                            withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                                                viewModel.togglePagamento(pagamentoID: pagamento.id, userId: uid)
                                            }
                                        }
                                    }
                                )
                            }
                        }
                    }
                    
                    // MARK: - Pagamentos Realizados
                    VStack(alignment: .leading, spacing: 16) {
                        HStack(spacing: 8) {
                            Circle().fill(Color.teal).frame(width: 8, height: 8)
                            Text("Já Pagaram")
                                .font(.title3.bold())
                        }
                        .padding(.top, 8)
                        
                        if viewModel.pagamentosRealizados.isEmpty {
                            Text("Nenhum recebimento registrado.")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                                .frame(maxWidth: .infinity, alignment: .center)
                                .padding()
                                .background(Color.white)
                                .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                        } else {
                            ForEach(viewModel.pagamentosRealizados) { pagamento in
                                let paciente = viewModel.paciente(for: pagamento)
                                PaidPaymentCard(
                                    pagamento: pagamento,
                                    nomePaciente: paciente?.name ?? "Desconhecido",
                                    mesFormatado: viewModel.formatarMesRefParaExibicao(pagamento.mesReferencia),
                                    onDesfazer: {
                                        // 3. Repassamos o ID do usuário para o ViewModel
                                        if let uid = authManager.usuarioID {
                                            withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                                                viewModel.togglePagamento(pagamentoID: pagamento.id, userId: uid)
                                            }
                                        }
                                    }
                                )
                            }
                        }
                    }
                    .padding(.bottom, 100)
                    
                }
                .padding(.horizontal, 20)
            }
            .navigationTitle("Finanças")
            .navigationBarTitleDisplayMode(.large)
            .onAppear {
                // 4. Carregamos os dados passando o ID do usuário
                if let uid = authManager.usuarioID {
                    viewModel.carregarDados(userId: uid)
                }
                
                if let monthPending = router.pendingMonth{
                    viewModel.currentDate = monthPending
                    viewModel.viewMode = .mensal
                    router.pendingMonth = nil
                }
            }
        }
    }
}
