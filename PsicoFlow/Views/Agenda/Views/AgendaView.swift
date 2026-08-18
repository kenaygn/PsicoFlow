//
//  AgendaView.swift
//  PsicoFlow
//
//  Created by Kenay on 08/04/26.
//

import SwiftUI

struct HorarioNovaSessaoContext: Identifiable {
    let id = UUID()
    let data: Date
    let horario: String
}

struct AgendaView: View {
    
    @EnvironmentObject var router: AppRouter

    @EnvironmentObject var authManager: AuthManager
    
    @StateObject private var viewModel = AgendaViewModel()
    
    // Estados de Navegação Programática
    @State private var pacienteSelecionado: Patient? = nil
    @State private var navegarParaProntuario: Bool = false
    
    // Estados de Modais
    @State private var contextoNovaSessao: HorarioNovaSessaoContext? = nil
    
    @State private var sessaoParaAcao: Session? = nil
    @State private var mostrarAcoesRapidas: Bool = false
    
    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 24) {
                    
                    if let dataDoProblema = viewModel.primeiraDataComConflito {
                        ConflictAlertCard(dataDoConflito: dataDoProblema) {
                            withAnimation(.spring(response: 0.5, dampingFraction: 0.75)) {
                                viewModel.pularParaData(dataDoProblema)
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 16)
                    }
                    
                    // MARK: - Controles do Calendário
                    HStack {
                        Text(viewModel.mesAnoAtual)
                            .font(.system(size: 22, weight: .bold))
                            .foregroundColor(Color(.darkText))
                        
                        Spacer()
                        
                        HStack(spacing: 12) {
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
                            
                            HStack(spacing: 8) {
                                Button(action: { withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) { viewModel.voltarSemana() } }) {
                                    Image(systemName: "chevron.left").font(.system(size: 14, weight: .bold)).foregroundColor(.gray).frame(width: 32, height: 32).background(Color(.systemGray6)).clipShape(Circle())
                                }
                                Button(action: { withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) { viewModel.avancarSemana() } }) {
                                    Image(systemName: "chevron.right").font(.system(size: 14, weight: .bold)).foregroundColor(.gray).frame(width: 32, height: 32).background(Color(.systemGray6)).clipShape(Circle())
                                }
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 8)
                    .padding(.bottom, -12)
                    
                    // MARK: - Seletor de Dias
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
                                        Text(viewModel.nomeCurtoDoDia(date)).font(.system(size: 11, weight: .semibold)).foregroundColor(isSelected ? .white.opacity(0.8) : (isToday ? .teal.opacity(0.8) : .secondary))
                                        Text(viewModel.numeroDoDia(date)).font(.system(size: 20, weight: .bold)).foregroundColor(isSelected ? .white : (isToday ? .teal : Color(.darkText)))
                                    }
                                    .frame(width: 60, height: 72)
                                    .background(isSelected ? (isToday ? Color.teal : Color(.darkText)) : Color.white)
                                    .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                                    .overlay(RoundedRectangle(cornerRadius: 16, style: .continuous).stroke(isToday && !isSelected ? Color.teal.opacity(0.3) : Color(.systemGray6), lineWidth: isSelected ? 0 : 1))
                                    .shadow(color: Color.black.opacity(isSelected ? 0.2 : 0.02), radius: 5, y: 3)
                                }
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.vertical, 10)
                    }
                    
                    // MARK: - Timeline
                    ZStack(alignment: .topLeading) {
                        Rectangle().fill(Color(.systemGray5)).frame(width: 2).padding(.leading, 63).padding(.top, 24)
                        
                        VStack(spacing: 24) {
                            ForEach(viewModel.timeSlots, id: \.self) { time in
                                let sessoesNoHorario = viewModel.sessoesPara(horario: time)
                                let isOccupied = !sessoesNoHorario.isEmpty
                                let isConflict = sessoesNoHorario.count > 1
                                
                                HStack(alignment: .top, spacing: 16) {
                                    HStack(spacing: 0) {
                                        Text(time).font(.system(size: 13, weight: .semibold)).foregroundColor(isConflict ? .red : .secondary).frame(width: 45, alignment: .trailing)
                                        Circle().fill(isConflict ? Color.red : (isOccupied ? Color.teal : Color(.systemGray5))).frame(width: 12, height: 12).padding(.leading, 10).offset(y: 4)
                                    }
                                    
                                    if sessoesNoHorario.isEmpty {
                                        EmptySlotCard {
                                            self.contextoNovaSessao = HorarioNovaSessaoContext(data: viewModel.selectedDate, horario: time)
                                        }
                                    } else {
                                        VStack(alignment: .leading, spacing: 8) {
                                            
                                            if isConflict {
                                                HStack(spacing: 4) {
                                                    Image(systemName: "exclamationmark.triangle.fill")
                                                    Text("Conflito de Horário")
                                                }
                                                .font(.system(size: 12, weight: .bold))
                                                .foregroundColor(.red)
                                                .padding(.bottom, 4)
                                            }
                                            
                                            ForEach(sessoesNoHorario) { sessao in
                                                if let paciente = viewModel.pacientePara(sessao: sessao) {
                                                    OccupiedSlotCard(sessao: sessao, paciente: paciente) {
                                                        self.sessaoParaAcao = sessao
                                                        self.pacienteSelecionado = paciente
                                                        self.mostrarAcoesRapidas = true
                                                    }
                                                    .overlay(
                                                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                                                            .stroke(isConflict ? Color.red : Color.clear, lineWidth: 2)
                                                    )
                                                }
                                            }
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
                if let uid = authManager.usuarioID {
                    viewModel.carregarDados(userId: uid)
                }
                
                if let conflictDay = router.conflictDay {
                    viewModel.pularParaData(conflictDay)
                    router.conflictDay = nil
                }
            }
            
            .navigationDestination(isPresented: $navegarParaProntuario) {
                if let paciente = pacienteSelecionado { PatientDetailView(paciente: paciente) }
            }
            
            .sheet(item: $contextoNovaSessao, onDismiss: {
                if let uid = authManager.usuarioID { viewModel.carregarDados(userId: uid) }
            }) { contexto in
                NewSessionView(dataSugerida: contexto.data, horarioSugerido: contexto.horario)
            }
            
            .sheet(isPresented: $mostrarAcoesRapidas) {
                if let sessao = sessaoParaAcao, let paciente = pacienteSelecionado {
                    SessionQuickActionView(
                        sessao: sessao,
                        paciente: paciente,
                        onUpdateStatus: { novoStatus, novaData in
                            if let uid = authManager.usuarioID {
                                withAnimation { viewModel.atualizarStatus(da: sessao, para: novoStatus, novaData: novaData, userId: uid) }
                            }
                        },
                        onOpenProfile: { self.navegarParaProntuario = true }
                    )
                }
            }
        }
    }
}
