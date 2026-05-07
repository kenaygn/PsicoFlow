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
    
    @StateObject private var viewModel = FinanceViewModel()
    
    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 24) {
                    
                    // MARK: - Filtro de Visualização
                    Picker("Modo de Visualização", selection: $viewModel.viewMode) {
                        Text("Mensal").tag(FinanceViewMode.mensal)
                        Text("Anual").tag(FinanceViewMode.anual)
                    }
                    .pickerStyle(.segmented)
                    .padding(.top, 8)
                    
                    // MARK: - Navegação de Período
                    HStack {
                        Button(action: {
                            viewModel.voltarPeriodo()
                        }) {
                            Image(systemName: "chevron.left")
                                .padding(12)
                                .background(Color(.systemGray6))
                                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                                .foregroundColor(.gray)
                        }
                        
                        Spacer()
                        
                        Text(viewModel.labelPeriodo)
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(Color(.darkText))
                        
                        Spacer()
                        
                        Button(action: {
                            viewModel.avancarPeriodo()
                        }) {
                            Image(systemName: "chevron.right")
                                .padding(12)
                                .background(Color(.systemGray6))
                                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                                .foregroundColor(.gray)
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
                            titulo: "A Receber",
                            valor: viewModel.totalPendenteText,
                            icone: "exclamationmark.circle.fill",
                            corTema: .red
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
                                    nomePaciente: paciente?.nome ?? "Desconhecido",
                                    iniciais: paciente?.iniciais ?? "?",
                                    mesFormatado: viewModel.formatarMesRefParaExibicao(pagamento.mesReferencia),
                                    onPagar: {
                                        withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                                            viewModel.togglePagamento(pagamentoID: pagamento.id)
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
                                    nomePaciente: paciente?.nome ?? "Desconhecido",
                                    mesFormatado: viewModel.formatarMesRefParaExibicao(pagamento.mesReferencia),
                                    onDesfazer: {
                                        withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                                            viewModel.togglePagamento(pagamentoID: pagamento.id)
                                        }
                                    }
                                )
                            }
                        }
                    }
                    // Note: Padding essencial para evitar que o último item seja ocultado pela TabBar do iOS.
                    .padding(.bottom, 100)
                    
                }
                .padding(.horizontal, 20)
            }
            .navigationTitle("Finanças")
            .navigationBarTitleDisplayMode(.large)
            .onAppear {
                viewModel.carregarDados()
            }
        }
    }
}

#Preview {
    FinancesView()
}
