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
    @State private var mostrarNovaSessao = false
    @State private var horarioSugerido: String = "08:00"
    
    // Gatilhos da Modal de Ação Rápida
    @State private var sessaoParaAcao: Session? = nil
    @State private var mostrarAcoesRapidas: Bool = false
    
    @State private var mostrarEdicaoDeSessao: Bool = false
    @State private var sessaoParaEditar: Session? = nil
    
    
    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 24) {
                    // --- 1. CABEÇALHO DA AGENDA (CONTROLES DE TEMPO) ---
                    HStack {
                        
                        Text(viewModel.mesAnoAtual)
                            .font(.system(size: 22, weight: .bold))
                            .foregroundColor(Color(.darkText))
                        
                        Spacer()
                        
                        // Lado Direito: Botão Hoje e Setas de Navegação
                        HStack(spacing: 12) {
                            
                            // Botão Hoje
                            Button(action: {
                                withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                                    viewModel.irParaHoje()
                                }
                            }) {
                                Text("Hoje")
                                    .font(.system(size: 13, weight: .bold))
                                    .foregroundColor(viewModel.isHojeSelecionado ? Color(.gray) : Color(.teal))
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 6)
                                    .background(viewModel.isHojeSelecionado ? Color(.systemGray6) : Color.teal.opacity(0.15))
                                    .clipShape(Capsule())
                            }
                            .disabled(viewModel.isHojeSelecionado)
                            
                            // Setinhas de Navegação
                            HStack(spacing: 8) {
                                Button(action: {
                                    withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                                        viewModel.voltarSemana()
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
                                        viewModel.avancarSemana()
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
                    .padding(.horizontal, 20)
                    .padding(.top, 8)
                    .padding(.bottom, -12)
                    
                    // --- 2. SELETOR DE DIAS DA SEMANA ---
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            ForEach(viewModel.weekDays, id: \.self) { date in
                                let isSelected = viewModel.isMesmoDia(date, viewModel.selectedDate)
                                let isToday = viewModel.isHoje(date)
                                
                                Button(action: {
                                    withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                                        viewModel.selecionarData(date)
                                    }
                                }) {
                                    VStack(spacing: 4) {
                                        Text(viewModel.nomeCurtoDoDia(date))
                                            .font(.system(size: 11, weight: .semibold))
                                            .foregroundColor(isSelected ? .white.opacity(0.8) : (isToday ? .teal.opacity(0.8) : .secondary))
                                        
                                        Text(viewModel.numeroDoDia(date))
                                            .font(.system(size: 20, weight: .bold))
                                            .foregroundColor(isSelected ? .white : (isToday ? .teal : Color(.darkText)))
                                    }
                                    .frame(width: 60, height: 72)
                                    .background(isSelected ? (isToday ? Color.teal : Color(.darkText)) : Color.white)
                                    .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                                            .stroke(isToday && !isSelected ? Color.teal.opacity(0.3) : Color(.systemGray6), lineWidth: isSelected ? 0 : 1)
                                    )
                                    .shadow(color: Color.black.opacity(isSelected ? 0.2 : 0.02), radius: 5, y: 3)
                                }
                            }
                        }
                        .padding(.horizontal, 20)
                    }
                    
                    // --- 3. LINHA DO TEMPO (TIMELINE) ---
                    ZStack(alignment: .topLeading) {
                        
                        // A Linha Vertical Decorativa (Fica no fundo)
                        Rectangle()
                            .fill(Color(.systemGray5))
                            .frame(width: 2)
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
                                            .offset(y: 4)
                                    }
                                    
                                    // Coluna da Direita: Cartões
                                    if let sessao = sessao, let paciente = viewModel.pacientePara(sessao: sessao) {
                                        // SLot Ocupado
                                        OccupiedSlotCard(sessao: sessao, paciente: paciente) {
                                            self.sessaoParaAcao = sessao
                                            self.pacienteSelecionado = paciente
                                            self.mostrarAcoesRapidas = true
                                        }
                                    } else {
                                        // Slot Vazio
                                        EmptySlotCard {
                                            self.horarioSugerido = time
                                            self.mostrarNovaSessao = true
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
            .navigationTitle("Agenda")
            .navigationBarTitleDisplayMode(.large)
            .onAppear {
                viewModel.carregarDados()
            }
            // Gatilho invisível de roteamento
            .navigationDestination(isPresented: $navegarParaProntuario) {
                if let paciente = pacienteSelecionado {
                    PatientDetailView(paciente: paciente)
                }
            }
            // Modal de Nova Sessão Avulsa
            .sheet(isPresented: $mostrarNovaSessao, onDismiss: {
                withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                    viewModel.carregarDados()
                }
            }) {
                NewSessionView(
                    dataSugerida: viewModel.selectedDate,
                    horarioSugerido: horarioSugerido
                )
            }
            // Modal de Ação Rápida (Bottom Sheet)
            .sheet(isPresented: $mostrarAcoesRapidas) {
                if let sessao = sessaoParaAcao, let paciente = pacienteSelecionado {
                    SessionQuickActionView(
                        sessao: sessao,
                        paciente: paciente,
                        onUpdateStatus: { novoStatus, novaData in
                            withAnimation {
                                viewModel.atualizarStatus(da: sessao, para: novoStatus, novaData: novaData)
                            }
                        },
                        onOpenProfile: {
                            self.navegarParaProntuario = true
                        }
                    )
                }
            }

        }
    }
}

#Preview {
    AgendaView()
}
