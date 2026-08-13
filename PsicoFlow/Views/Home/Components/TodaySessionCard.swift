//
//  TodaySessionCard.swift
//  PsicoApp
//
//  Created by Kenay on 02/04/26.
//

import SwiftUI

/// Card interativo que exibe uma sessão agendada para o dia atual.
/// Adapta seu estilo visual para destacar a sessão imediata (`isNext`)
struct TodaySessionCard: View {
    
    var session: Session
    var nomePaciente: String
    var iniciaisPaciente: String
    var isNext: Bool
    
    var onSelectPaciente: () -> Void
    var onUpdateStatus: (SessionStatus, Date?) -> Void
    var fetchAvailableTimes: (Date, String) async -> [String]
    
    @State private var mostrandoAdiar = false
    @State private var novaData = Date()
    @State private var novaHoraStr = ""
    
    // Novos estados para gerenciar a chamada assíncrona do Firebase
    @State private var horariosLivres: [String] = []
    @State private var estaCarregandoHorarios = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            
            // MARK: - Cabeçalho (Relógio e Status/A Seguir)
            HStack {
                HStack(spacing: 6) {
                    Image(systemName: "clock")
                        .font(.system(size: 14))
                    Text(session.horaInicio)
                        .font(.system(size: 16, weight: .semibold))
                }
                .foregroundColor(isNext ? .white : .primary)
                
                Spacer()
                
                if isNext {
                    Text("A SEGUIR")
                        .font(.system(size: 10, weight: .bold))
                        .textCase(.uppercase)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.teal)
                        .foregroundColor(.white)
                        .clipShape(Capsule())
                } else {
                    HStack(spacing: 6) {
                        
                        // Botão de Desfazer (Aparece apenas se estiver cancelada)
                        if session.status == .cancelada {
                            Button(action: {
                                // Reverte o status para agendada
                                onUpdateStatus(.agendada, nil)
                            }) {
                                Image(systemName: "arrow.uturn.backward")
                                    .font(.system(size: 12, weight: .bold))
                                    .foregroundColor(.red)
                                    .padding(6)
                                    .background(Color.red.opacity(0.15))
                                    .clipShape(Circle())
                            }
                            .buttonStyle(.plain) // Evita que o clique vaze para o Card inteiro
                        }
                        
                        Text(session.status.rawValue.capitalized)
                            .font(.system(size: 10, weight: .bold))
                            .textCase(.uppercase)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(corBadge(status: session.status).opacity(0.15))
                            .foregroundColor(corBadge(status: session.status))
                            .clipShape(Capsule())
                        
                    }
                }
            }
            
            // MARK: - Informações do Paciente e Detalhes Operacionais
            HStack(spacing: 12) {
                Circle()
                    .fill(isNext ? Color.white : Color.gray.opacity(0.1))
                    .frame(width: 40, height: 40)
                    .overlay(
                        Text(iniciaisPaciente)
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(isNext ? .black : .primary)
                    )
                
                VStack(alignment: .leading, spacing: 6) {
                    Text(nomePaciente)
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundColor(isNext ? .white : .primary)
                    
                    HStack(spacing: 12) {
                        
                        if session.sessaoFixaID != nil {
                            HStack(spacing: 4) {
                                Image(systemName: "repeat")
                                Text("Fixa")
                            }
                            .foregroundColor(Color(red: 0.89, green: 0.25, blue: 0.35))
                        } else {
                            HStack(spacing: 4) {
                                Image(systemName: "1.circle")
                                Text("Avulsa")
                            }
                            .foregroundColor(.orange)
                        }
                        
                        HStack(spacing: 4) {
                            Image(systemName: session.modalidade.rawValue.lowercased() == "online" ? "video" : "person.2")
                            Text(session.modalidade.rawValue.capitalized)
                        }
                        .foregroundColor(isNext ? .gray : .secondary)
                        
                        HStack(spacing: 4) {
                            Image(systemName: "clock")
                            Text("50 min")
                        }
                        .foregroundColor(isNext ? .gray : .secondary)
                    }
                    .font(.system(size: 13, weight: .medium))
                }
                Spacer()
            }
            
            // MARK: - Controles de Ação
            if session.status == .agendada {
                Divider()
                    .background(isNext ? Color.gray.opacity(0.3) : Color.gray.opacity(0.1))
                    .padding(.top, 4)
                
                if mostrandoAdiar {
                    // MARK: Modo Reagendamento
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Reagendar para:")
                            .font(.caption.bold())
                            .foregroundColor(isNext ? .gray : .secondary)
                        
                        HStack {
                            DatePicker("", selection: $novaData, displayedComponents: .date)
                                .labelsHidden()
                                .environment(\.locale, Locale(identifier: "pt_BR"))
                                .environment(\.colorScheme, isNext ? .dark : .light)
                            
                            Picker("Horário", selection: $novaHoraStr) {
                                if estaCarregandoHorarios {
                                    Text("Buscando...").tag("")
                                } else if horariosLivres.isEmpty {
                                    Text("Lotado").tag("")
                                } else {
                                    ForEach(horariosLivres, id: \.self) { horario in
                                        Text(horario).tag(horario)
                                    }
                                }
                            }
                            .pickerStyle(.menu)
                            .padding(.horizontal, 2)
                            .padding(.vertical, 1)
                            .background(isNext ? Color.white.opacity(0.1) : Color(.systemGray6))
                            .foregroundColor(isNext ? .white : .primary)
                            .clipShape(RoundedRectangle(cornerRadius: 80, style: .continuous))
                            .environment(\.colorScheme, isNext ? .dark : .light)
                            .disabled(horariosLivres.isEmpty || estaCarregandoHorarios)
                            
                            Spacer()
                        }
                        
                        HStack {
                            Button(action: {
                                withAnimation { mostrandoAdiar = false }
                            }) {
                                Text("Cancelar")
                                    .font(.caption.bold())
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 10)
                                    .contentShape(Rectangle())
                                    .background(.red.opacity(0.1))
                                    .foregroundColor(.red)
                                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                            }
                            .buttonStyle(.plain)
                            
                            Button(action: {
                                let dataFinal = combinarDataEHora(data: novaData, horaString: novaHoraStr)
                                onUpdateStatus(.adiada, dataFinal)
                                mostrandoAdiar = false
                            }) {
                                Text("Salvar")
                                    .font(.caption.bold())
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 10)
                                    .contentShape(Rectangle())
                                    .background(Color.teal)
                                    .foregroundColor(.white)
                                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                            }
                            .buttonStyle(.plain)
                            .disabled(horariosLivres.isEmpty || novaHoraStr.isEmpty || estaCarregandoHorarios)
                        }
                    }
                    .padding(.top, 4)
                    
                } else {
                    // MARK: Botões Padrão
                    HStack(spacing: 8) {
                        actionButton(title: "Realizada", icon: "checkmark.circle", isNext: isNext, color: .green) {
                            onUpdateStatus(.realizada, nil)
                        }
                        actionButton(title: "Adiada", icon: "calendar.badge.clock", isNext: isNext, color: .orange) {
                            novaData = session.dataDaSessao
                            novaHoraStr = session.horaInicio
                            withAnimation { mostrandoAdiar = true }
                            // Carrega horários assincronamente ao abrir o reagendamento
                            carregarHorarios(para: novaData)
                        }
                        actionButton(title: "Cancelada", icon: "xmark.circle", isNext: isNext, color: .red) {
                            onUpdateStatus(.cancelada, nil)
                        }
                    }
                    .padding(.top, 4)
                }
            }
        }
        .padding(16)
        .overlay(alignment: .topTrailing) {
            if isNext {
                Circle()
                    .fill(.white.opacity(0.05))
                    .frame(width: 130, height: 130)
                    .offset(x: 25, y: -40)
            }
        }
        .contentShape(Rectangle())
        .onTapGesture {
            if !mostrandoAdiar { onSelectPaciente() }
        }
        .background(isNext ? Color(red: 15/255, green: 23/255, blue: 42/255) : Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .stroke(isNext ? Color.clear : Color.gray.opacity(0.1), lineWidth: 1)
        )
        .shadow(color: Color.black.opacity(isNext ? 0.15 : 0.03), radius: 8, x: 0, y: 4)
        .onChange(of: novaData) { _ in
            if mostrandoAdiar {
                carregarHorarios(para: novaData)
            }
        }
    }
    
    // MARK: - Lógica Assíncrona
    
    private func carregarHorarios(para data: Date) {
        Task {
            estaCarregandoHorarios = true
            let novosHorarios = await fetchAvailableTimes(data, session.id)
            
            await MainActor.run {
                self.horariosLivres = novosHorarios
                // Ajusta a hora selecionada se a atual não estiver disponível na nova data
                if !novosHorarios.contains(novaHoraStr) {
                    novaHoraStr = novosHorarios.first ?? ""
                }
                estaCarregandoHorarios = false
            }
        }
    }
    
    // MARK: - Helpers
    
    @ViewBuilder
    private func actionButton(title: String, icon: String, isNext: Bool, color: Color, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 4) {
                Image(systemName: icon)
                Text(title)
            }
            .font(.system(size: 11, weight: .bold))
            .textCase(.uppercase)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 10)
            .background(isNext ? Color.white.opacity(0.1) : color.opacity(0.1))
            .foregroundColor(isNext ? .white : color)
            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
        }
    }
    
    private func combinarDataEHora(data: Date, horaString: String) -> Date {
        let partes = horaString.split(separator: ":")
        guard partes.count == 2, let hora = Int(partes[0]), let minuto = Int(partes[1]) else { return data }
        return Calendar.current.date(bySettingHour: hora, minute: minuto, second: 0, of: data) ?? data
    }
    
    private func corBadge(status: SessionStatus) -> Color {
        switch status {
        case .realizada: return .gray
        case .agendada: return .teal
        case .adiada: return .orange
        case .cancelada: return .red
        }
    }
}
