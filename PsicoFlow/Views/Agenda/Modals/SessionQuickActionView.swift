//
//  SessionQuickActionView.swift
//  PsicoFlow
//
//  Created by Kenay on 13/04/26.
//

import SwiftUI

/// Modal de acesso rápido (Bottom Sheet) para gerenciamento de status de uma sessão.
struct SessionQuickActionView: View {
    
    let paciente: Patient
    let onUpdateStatus: (SessionStatus, Date?) -> Void
    let onOpenProfile: () -> Void
    
    // 1. Injetamos o gerenciador de autenticação
    @EnvironmentObject var authManager: AuthManager
    @Environment(\.dismiss) var dismiss
    
    @StateObject private var viewModel: SessionQuickActionViewModel
    
    @State private var mostrandoAdiar = false
    @State private var alturaModal: PresentationDetent = .height(360)
        
    init(
        sessao: Session,
        paciente: Patient,
        onUpdateStatus: @escaping (SessionStatus, Date?) -> Void,
        onOpenProfile: @escaping () -> Void
    ) {
        self.paciente = paciente
        self.onUpdateStatus = onUpdateStatus
        self.onOpenProfile = onOpenProfile
        _viewModel = StateObject(wrappedValue: SessionQuickActionViewModel(sessao: sessao))
    }
        
    var body: some View {
        VStack(spacing: 24) {
            
            // MARK: - Cabeçalho
            VStack(spacing: 8) {
                Text(String(paciente.name.prefix(1)))
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(.teal)
                    .frame(width: 64, height: 64)
                    .background(Color.teal.opacity(0.15))
                    .clipShape(Circle())
                
                Text(paciente.name)
                    .font(.system(size: 22, weight: .bold))
                    .foregroundColor(Color(.darkText))
                
                HStack(spacing: 12) {
                    Label(viewModel.sessao.startTime, systemImage: "clock")
                    Text("•")
                    Label(viewModel.sessao.status.rawValue.capitalized, systemImage: "circle.fill")
                        .foregroundColor(corBadge(status: viewModel.sessao.status))
                }
                .font(.system(size: 15, weight: .medium))
                .foregroundColor(.secondary)
            }
            .padding(.top, 24)
            
            // MARK: - Controles
            ZStack {
                if mostrandoAdiar {
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Reagendar para:")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(.secondary)
                        
                        HStack {
                            DatePicker("Data", selection: $viewModel.novaData, displayedComponents: .date)
                                .labelsHidden()
                                .environment(\.locale, Locale(identifier: "pt_BR"))
                            
                            Picker("Horário", selection: $viewModel.novaHoraStr) {
                                // Exibe carregando ou lista vazia
                                if viewModel.horariosLivres.isEmpty {
                                    Text("Buscando...").tag("")
                                } else {
                                    ForEach(viewModel.horariosParaOPicker, id: \.self) { horario in
                                        Text(horario).tag(horario)
                                    }
                                }
                            }
                            .pickerStyle(.menu)
                            .padding(.horizontal, 2)
                            .padding(.vertical, 1)
                            .background(Color(.systemGray5))
                            .clipShape(RoundedRectangle(cornerRadius: 120, style: .continuous))
                            .disabled(viewModel.horariosLivres.isEmpty)
                            
                            Spacer()
                        }
                        
                        HStack(spacing: 12) {
                            Button("Cancelar") {
                                withAnimation(.spring(response: 0.4, dampingFraction: 0.75)) {
                                    mostrandoAdiar = false
                                    alturaModal = .height(360)
                                }
                            }
                            .font(.system(size: 15, weight: .bold))
                            .foregroundColor(.red)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .background(Color.red.opacity(0.1))
                            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                            
                            Button("Salvar") {
                                let dataFinal = viewModel.obterDataFinal()
                                onUpdateStatus(.postponed, dataFinal)
                                dismiss()
                            }
                            .font(.system(size: 15, weight: .bold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .background(Color.teal)
                            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                            .disabled(viewModel.novaHoraStr.isEmpty)
                        }
                    }
                    .padding(.horizontal, 20)
                } else {
                    HStack(spacing: 12) {
                        actionButton(title: "Realizada", icon: "checkmark.circle.fill", color: .green) {
                            onUpdateStatus(.completed, nil)
                            dismiss()
                        }
                        actionButton(title: "Adiada", icon: "calendar.badge.clock", color: .orange) {
                            withAnimation(.spring(response: 0.4, dampingFraction: 0.75)) {
                                mostrandoAdiar = true
                                alturaModal = .height(420)
                                // Dispara a primeira busca ao abrir
                                if let uid = authManager.userID { viewModel.carregarHorariosLivres(userId: uid) }
                            }
                        }
                        actionButton(title: "Cancelada", icon: "xmark.circle.fill", color: .red) {
                            onUpdateStatus(.cancelled, nil)
                            dismiss()
                        }
                    }
                    .padding(.horizontal, 20)
                }
            }
            
            Divider().padding(.horizontal, 20)
            
            Button(action: {
                dismiss()
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { onOpenProfile() }
            }) {
                HStack {
                    Image(systemName: "person.text.rectangle")
                    Text("Abrir Prontuário Completo")
                }
                .font(.system(size: 17, weight: .semibold))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(Color(.darkText))
                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                .padding(.horizontal, 20)
            }
            Spacer()
        }
        .presentationDetents([.height(360), .height(420)], selection: $alturaModal)
        .presentationDragIndicator(.visible)
        // 2. Sempre que a data mudar, busca os novos horários
        .onChange(of: viewModel.novaData) { _ in
            if let uid = authManager.userID {
                viewModel.carregarHorariosLivres(userId: uid)
            }
        }
    }
    
    // MARK: - Helpers
    @ViewBuilder
    private func actionButton(title: String, icon: String, color: Color, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(systemName: icon).font(.system(size: 24))
                Text(title).font(.system(size: 12, weight: .bold))
            }
            .foregroundColor(color)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(color.opacity(0.1))
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        }
    }
    
    private func corBadge(status: SessionStatus) -> Color {
        switch status {
        case .completed: return .gray
        case .scheduled: return .teal
        case .postponed: return .orange
        case .cancelled: return .red
        }
    }
}
