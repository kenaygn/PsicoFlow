//
//  NextSessionMainCard.swift
//  PsicoApp
//
//  Created by Kenay on 02/04/26.
//

import SwiftUI

/// Card de destaque principal (Hero) que exibe a sessão imediata do psicólogo.
struct NextSessionMainCard: View {
        
    var session: Session
    var nomeDaPaciente: String
    var onAbrirProntuario: () -> Void
    
    @State private var isPulsing = false
    
    var body: some View {
        Button(action: onAbrirProntuario) {
            ZStack {
                
//                Gradiente interessante para algum outro lugar
//                LinearGradient(
//                    colors: [
//                        Color(red: 20/255, green: 184/255, blue: 166/255), // Teal 500
//                        Color(red: 15/255, green: 118/255, blue: 110/255)  // Teal 700
//                    ],
//                    startPoint: .topLeading,
//                    endPoint: .bottomTrailing
//                )
                
                // MARK: - Background Gradient (Dark Slate / Foco)
                                LinearGradient(
                                    colors: [
                                        Color(red: 30/255, green: 41/255, blue: 59/255),
                                        Color(red: 15/255, green: 23/255, blue: 42/255)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                
                // MARK: - Elementos Decorativos (Padrão Global)
                GeometryReader { geo in
                    Circle()
                        .fill(Color.white.opacity(0.15))
                        .frame(width: 120, height: 120)
                        .blur(radius: 20)
                        .position(x: geo.size.width + 10, y: -10)
                    
                    Image(systemName: "clock.fill")
                        .font(.system(size: 140))
                        .foregroundColor(Color.white.opacity(0.1))
                        .position(x: geo.size.width - 20, y: geo.size.height / 2 + 10)
                }
                .clipped()
                
                // MARK: - Conteúdo Principal
                VStack(alignment: .leading, spacing: 12) {
                    
                    // Header com a Tag e o Horário
                    HStack {
                        HStack(spacing: 6) {
                            // Ponto pulsante integrado à tag
                            ZStack {
                                Circle()
                                    .fill(Color.white)
                                    .frame(width: 6, height: 6)
                                    .scaleEffect(isPulsing ? 2.0 : 1.0)
                                    .opacity(isPulsing ? 0.0 : 0.8)
                                    .animation(.easeInOut(duration: 1.5).repeatForever(autoreverses: false), value: isPulsing)
                                
                                Circle()
                                    .fill(Color.white)
                                    .frame(width: 4, height: 4)
                            }
                            .onAppear { isPulsing = true }
                            
                            Text("PRÓXIMA SESSÃO")
                                .font(.system(size: 10, weight: .bold))
                                .tracking(1)
                        }
                        .padding(.horizontal, 10)
                        .padding(.vertical, 5)
                        .background(Color.white.opacity(0.25))
                        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                        
                        Spacer()
                        
                        // Tag de Horário no topo direito
                        Text(session.horaInicio)
                            .font(.system(size: 12, weight: .bold))
                            .padding(.horizontal, 10)
                            .padding(.vertical, 5)
                            .background(Color.white.opacity(0.2))
                            .clipShape(Capsule())
                    }
                    
                    // Corpo do Texto
                    VStack(alignment: .leading, spacing: 4) {
                        Text(nomeDaPaciente)
                            .font(.title3)
                            .fontWeight(.bold)
                        
                        Text("Tudo pronto para o atendimento. ")
                            .font(.subheadline)
                            .foregroundColor(Color.white.opacity(0.9))
                        + Text("Toque para abrir o prontuário completo.")
                            .font(.subheadline)
                            .fontWeight(.bold)
                            .foregroundColor(Color.white.opacity(0.9))
                    }
                }
                .padding(20)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .frame(height: 152)
            .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
            .shadow(color: Color(red: 15/255, green: 23/255, blue: 42/255).opacity(0.3), radius: 10, x: 0, y: 5)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    NextSessionMainCard(
        session: MockData.sessoesExemplo.first!,
        nomeDaPaciente: "Sarah Connor",
        onAbrirProntuario: { print("Navegar") }
    )
    .padding()
}
