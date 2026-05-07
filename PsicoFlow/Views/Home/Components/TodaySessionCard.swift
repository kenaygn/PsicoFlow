//
//  TodaySessionCard.swift
//  PsicoApp
//
//  Created by Kenay on 02/04/26.
//

import SwiftUI

/// Card interativo que exibe uma sessão agendada para o dia atual.
/// Adapta seu estilo visual para destacar a sessão imediata (`isNext`) e
/// permite ações rápidas de status (Realizada, Adiada, Cancelada) e reagendamento inline.
struct TodaySessionCard: View {
        
    var session: Session
    var nomePaciente: String
    var iniciaisPaciente: String
    var isNext: Bool
    
    var onSelectPaciente: () -> Void
    var onUpdateStatus: (SessionStatus, Date?) -> Void
    var fetchAvailableTimes: (Date, String) -> [String]
    
    @State private var mostrandoAdiar = false
    @State private var novaData = Date()
    @State private var novaHoraStr = ""
    
    private var horariosLivres: [String] {
        fetchAvailableTimes(novaData, session.id)
    }
        
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            
            // MARK: - Cabeçalho
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
                }
            }
            
            // MARK: - Informações do Paciente
            HStack(spacing: 12) {
                Circle()
                    .fill(isNext ? Color.white : Color.gray.opacity(0.1))
                    .frame(width: 40, height: 40)
                    .overlay(
                        Text(iniciaisPaciente)
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(isNext ? .black : .primary)
                    )
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(nomePaciente)
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundColor(isNext ? .white : .primary)
                    
                    Text(session.status.rawValue)
                        .font(.system(size: 13))
                        .foregroundColor(isNext ? .gray : .secondary)
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
                                if horariosLivres.isEmpty {
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
                            .disabled(horariosLivres.isEmpty)
                            
                            Spacer()
                        }
                        
                        HStack {
                            Button("Cancelar") {
                                withAnimation { mostrandoAdiar = false }
                            }
                            .font(.caption.bold())
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 10)
                            .background(.red.opacity(0.1))
                            .foregroundColor(.red)
                            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                            
                            Button("Salvar") {
                                let dataFinal = combinarDataEHora(data: novaData, horaString: novaHoraStr)
                                onUpdateStatus(.adiada, dataFinal)
                                mostrandoAdiar = false
                            }
                            .font(.caption.bold())
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 10)
                            .background(Color.teal)
                            .foregroundColor(.white)
                            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                            .disabled(horariosLivres.isEmpty || novaHoraStr.isEmpty)
                        }
                    }
                    .padding(.top, 4)
                    
                } else {
                    
                    // MARK: Botões Padrão
                    HStack(spacing: 8) {
                        actionButton(title: "Realizada", icon: "checkmark.circle", isNext: isNext, color: .green) {
                            onUpdateStatus(.realizada, nil)
                        }
                        actionButton(title: "Adiada", icon: "calendar.badge.clock", isNext: isNext, color: .blue) {
                            novaData = session.dataDaSessão
                            novaHoraStr = session.horaInicio
                            withAnimation { mostrandoAdiar = true }
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
            // Note: Previne que o sistema mantenha uma hora selecionada que não
            // está disponível no novo dia selecionado pelo usuário.
            if !horariosLivres.contains(novaHoraStr) {
                novaHoraStr = horariosLivres.first ?? ""
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
}
