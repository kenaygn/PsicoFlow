//
//  WeeklySummaryCard.swift
//  PsicoApp
//
//  Created by Kenay on 02/04/26.
//

import SwiftUI

struct WeeklySummaryCard: View {
    var atendimentosNaSemana: Int
    var onVerDesempenho: () -> Void = {}
    
    var body: some View {
        ZStack {
            // 1. Fundo Gradiente (Equivalente ao amber-400 -> orange-500)
            LinearGradient(
                colors: [
                    Color(red: 251/255, green: 191/255, blue: 36/255),
                    Color(red: 249/255, green: 115/255, blue: 22/255)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            
            // 2. Decorações de Fundo (Absolute)
            GeometryReader { geo in
                // Círculo borrado no canto superior direito
                Circle()
                    .fill(Color.white.opacity(0.2))
                    .frame(width: 120, height: 120)
                    .blur(radius: 24)
                    .position(x: geo.size.width + 10, y: -10)
                
                // Ícone gigante e translúcido no canto inferior direito
                Image(systemName: "flame.fill")
                    .font(.system(size: 180))
                    .foregroundColor(Color.white.opacity(0.15))
                    .position(x: geo.size.width - 20, y: geo.size.height/2 + 20)
            }
            .clipped() // Garante que as decorações não vazem do cartão
            
            // 3. Conteúdo Principal
            VStack(alignment: .leading, spacing: 16) {
                
                // Tag estilo "Plano Pro"
                Text("RESUMO DA SEMANA")
                    .font(.system(size: 10, weight: .bold))
                    .tracking(1)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(Color.white.opacity(0.25))
                    .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                
                // Textos
                VStack(alignment: .leading, spacing: 4) {
                    Text("Atendimentos em Dia!")
                        .font(.title3)
                        .fontWeight(.bold)
                    
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
            .foregroundColor(.white) // Força todos os textos não estilizados a ficarem brancos
        }
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
        // Sombra alaranjada para dar um brilho no fundo
        .shadow(color: Color(red: 249/255, green: 115/255, blue: 22/255).opacity(0.3), radius: 15, x: 0, y: 8)
    }
}
