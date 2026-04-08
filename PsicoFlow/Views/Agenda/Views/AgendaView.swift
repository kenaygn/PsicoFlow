//
//  AgendaView.swift
//  PsicoFlow
//
//  Created by Kenay on 08/04/26.
//

import SwiftUI

struct AgendaView: View {
    @StateObject private var viewModel = AgendaViewModel()
    
    // Gatilhos de Navegação Programática
    @State private var pacienteSelecionado: Patient? = nil
    @State private var navegarParaProntuario: Bool = false
    
    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 24) {
                    
                    // --- 1. SELETOR DE DIAS DA SEMANA ---
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            ForEach(viewModel.weekDays, id: \.self) { date in
                                let isSelected = viewModel.isMesmoDia(date, viewModel.selectedDate)
                                
                                Button(action: {
                                    withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                                        viewModel.selecionarData(date)
                                    }
                                }) {
                                    VStack(spacing: 4) {
                                        Text(viewModel.nomeCurtoDoDia(date))
                                            .font(.system(size: 11, weight: .semibold))
                                            .foregroundColor(isSelected ? Color.white.opacity(0.8) : .secondary)
                                        
                                        Text(viewModel.numeroDoDia(date))
                                            .font(.system(size: 20, weight: .bold))
                                            .foregroundColor(isSelected ? .white : Color(.darkText))
                                    }
                                    .frame(width: 60, height: 72)
                                    .background(isSelected ? Color(.darkText) : Color.white)
                                    .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                                            .stroke(Color(.systemGray6), lineWidth: isSelected ? 0 : 1)
                                    )
                                    .shadow(color: Color.black.opacity(isSelected ? 0.2 : 0.02), radius: 5, y: 3)
                                }
                            }
                        }
                        .padding(.horizontal, 20)
                    }
                    .padding(.top, 8)
                    
                    // --- 2. LINHA DO TEMPO (TIMELINE) ---
                    ZStack(alignment: .topLeading) {
                        
                        // A Linha Vertical Decorativa (Fica no fundo)
                        Rectangle()
                            .fill(Color(.systemGray5))
                            .frame(width: 2)
                            // Movemos a linha para alinhar com os pontinhos (ajuste fino)
                            .padding(.leading, 63)
                            .padding(.top, 24)
                        
                        // Os Horários e os Cartões
                        VStack(spacing: 24) {
                            ForEach(viewModel.timeSlots, id: \.self) { time in
                                let sessao = viewModel.sessaoPara(horario: time)
                                let isOccupied = sessao != nil
                                
                                HStack(alignment: .top, spacing: 16) {
                                    
                                    // Coluna da Esquerda: Horário e Pontinho
                                    HStack(spacing: 0) {
                                        Text(time)
                                            .font(.system(size: 13, weight: .semibold))
                                            .foregroundColor(.secondary)
                                            .frame(width: 45, alignment: .trailing)
                                        
                                        // O Pontinho na linha
                                        Circle()
                                            .fill(isOccupied ? Color.teal : Color(.systemGray5))
                                            .frame(width: 12, height: 12)
                                            .overlay(Circle().stroke(Color(.systemGroupedBackground), lineWidth: 3))
                                            .padding(.leading, 10)
                                            // Ajuda a alinhar perfeitamente no topo do cartão
                                            .offset(y: 4)
                                    }
                                    
                                    // Coluna da Direita: Cartões
                                    if let sessao = sessao, let paciente = viewModel.pacientePara(sessao: sessao) {
                                        // SLot Ocupado
                                        OccupiedSlotCard(sessao: sessao, paciente: paciente) {
                                            // Dispara a navegação
                                            self.pacienteSelecionado = paciente
                                            self.navegarParaProntuario = true
                                        }
                                    } else {
                                        // Slot Vazio
                                        EmptySlotCard {
                                            print("Abrir modal de Nova Sessão para às \(time)")
                                        }
                                    }
                                }
                            }
                        }
                        .padding(.horizontal, 20)
                    }
                }
                .padding(.bottom, 100)
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Agenda")
            .navigationBarTitleDisplayMode(.large)
            .onAppear {
                viewModel.carregarDados()
            }
            // Gatilho invisível de roteamento (Clean Navigation)
            .navigationDestination(isPresented: $navegarParaProntuario) {
                if let paciente = pacienteSelecionado {
                    PatientDetailView(paciente: paciente)
                }
            }
        }
    }
}

#Preview {
    AgendaView()
}
