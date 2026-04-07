//
//  TodaySessionCard.swift
//  PsicoApp
//
//  Created by Kenay on 02/04/26.
//

import SwiftUI

struct TodaySessionCard: View {
    var session: Session
    var nomePaciente: String
    var iniciaisPaciente: String
    
    // IMPORTANTE: Nova variável que diz se o cartão deve ficar escuro
    var isNext: Bool
    
    var onSelectPaciente: () -> Void
    var onUpdateStatus: (SessionStatus, Date?) -> Void
    
    @State private var mostrandoAdiar = false
    @State private var novaData = Date()
    
    var body: some View {
        // Tudo fica dentro do cartão agora
        VStack(alignment: .leading, spacing: 16) {
            
            // 1. TOPO: Relógio, Horário e Tag "A seguir"
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
            
            // 2. MEIO: Avatar, Nome e Status
            HStack(spacing: 12) {
                Circle()
                    // Fundo branco se o card for escuro, cinza se o card for branco
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
            
            // 3. BASE: Botões de Ação (Apenas se Agendada)
            if session.status == .agendada {
                Divider()
                    .background(isNext ? Color.gray.opacity(0.3) : Color.gray.opacity(0.1))
                    .padding(.top, 4)
                
                if mostrandoAdiar {
                    // Estado: Escolhendo data e hora
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Reagendar para:")
                            .font(.caption.bold())
                            .foregroundColor(isNext ? .gray : .secondary)
                        
                        HStack {
                            // A MÁGICA AQUI: [.date, .hourAndMinute]
                            DatePicker("", selection: $novaData, displayedComponents: [.date, .hourAndMinute])
                                .labelsHidden()
                                // Força o formato de 24h (ex: 14:30) muito usado no Brasil
                                .environment(\.locale, Locale(identifier: "pt_BR"))
                                .environment(\.colorScheme, isNext ? .dark : .light)
                        }
                        
                        HStack {
                            // Botão de voltar atrás
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
                                onUpdateStatus(.adiada, novaData)
                                mostrandoAdiar = false
                            }
                            .font(.caption.bold())
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 10)
                            .background(Color.teal)
                            .foregroundColor(.white)
                            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))

                        }
                    }
                    .padding(.top, 4)
                } else {
                    // Estado: Botões Padrão
                    HStack(spacing: 8) {
                        actionButton(title: "Realizada", icon: "checkmark.circle", isNext: isNext, color: .green) {
                            onUpdateStatus(.realizada, nil)
                        }
                        actionButton(title: "Adiada", icon: "calendar.badge.clock", isNext: isNext, color: .blue) {
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
            if isNext{
                Circle()
                    .fill(.white.opacity(0.05))
                    .frame(width: 130, height: 130)
                    .offset(x: 25, y: -40) // Empurra pra fora do card
            }

        }
        // 2. A MÁGICA DO CLIQUE:
        // O contentShape garante que clicar no espaço em branco também funcione
        .contentShape(Rectangle())
        .onTapGesture {
            // Dispara a navegação apenas se o usuário não estava clicando nos botõezinhos de status
            if !mostrandoAdiar {
                onSelectPaciente()
            }
        }
        // O fundo do cartão muda dependendo da variável isNext (Slate-900 ou Branco)
        .background(isNext ? Color(red: 15/255, green: 23/255, blue: 42/255) : Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                // Se for escuro não tem borda, se for branco tem bordinha fina
                .stroke(isNext ? Color.clear : Color.gray.opacity(0.1), lineWidth: 1)
        )
        // Sombra mais forte se for o card em destaque
        .shadow(color: Color.black.opacity(isNext ? 0.15 : 0.03), radius: 8, x: 0, y: 4)
    }
    
    // Função auxiliar para montar os botõezinhos mantendo o visual do React
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
            // Se o card for escuro, fundo transparente branco. Se for claro, usa o fundo da própria cor.
            .background(isNext ? Color.white.opacity(0.1) : color.opacity(0.1))
            .foregroundColor(isNext ? .white : color)
            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
        }
    }
}
