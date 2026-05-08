//
//  WeeklySummaryCard.swift
//  PsicoApp
//
//  Created by Kenay on 02/04/26.
//

import SwiftUI

/// Card comemorativo exibido quando o psicólogo não possui mais sessões pendentes no dia.
struct WeeklySummaryCard: View {
        
    var atendimentosNaSemana: Int
            
    var body: some View {
        ZStack {
            
            // MARK: - Background & Decorações
            LinearGradient(
                colors: [
                    Color(red: 251/255, green: 191/255, blue: 36/255),
                    Color(red: 249/255, green: 115/255, blue: 22/255)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            
            GeometryReader { geo in
                Circle()
                    .fill(Color.white.opacity(0.2))
                    .frame(width: 120, height: 120)
                    .blur(radius: 24)
                    .position(x: geo.size.width + 10, y: -10)
                
                Image(systemName: "flame.fill")
                    .font(.system(size: 180))
                    .foregroundColor(Color.white.opacity(0.15))
                    .position(x: geo.size.width - 20, y: geo.size.height / 2 + 20)
            }
            .clipped()
            
            // MARK: - Conteúdo Principal
            VStack(alignment: .leading, spacing: 16) {
                
                Text("RESUMO DA SEMANA")
                    .font(.system(size: 10, weight: .bold))
                    .tracking(1)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(Color.white.opacity(0.25))
                    .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("Atendimentos em Dia!")
                        .font(.title3)
                        .fontWeight(.bold)
                    
                    // O uso do operador '+' concatena os blocos de texto preservando a formatação individual
                    Text("Você já concluiu ")
                        .font(.subheadline)
                        .foregroundColor(Color.white.opacity(0.9))
                    + Text("\(atendimentosNaSemana) atendimentos")
                        .font(.subheadline)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    + Text(" esta semana. Aproveite o seu merecido descanso.")
                        .font(.subheadline)
                        .foregroundColor(Color.white.opacity(0.9))
                }
                .padding(.bottom, 4)
                
            }
            .padding(20)
            .foregroundColor(.white)
        }
        .frame(height: 152)
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
        .shadow(color: Color(red: 249/255, green: 115/255, blue: 22/255).opacity(0.3), radius: 15, x: 0, y: 8)
    }
}

#Preview {
    WeeklySummaryCard(atendimentosNaSemana: 20)
}
