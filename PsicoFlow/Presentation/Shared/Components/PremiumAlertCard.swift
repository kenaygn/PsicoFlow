//
//  PremiumAlertCard.swift
//  PsicoFlow
//
//  Created by Kenay on 01/06/26.
//

import SwiftUI

// TODO: Mostrar apenas quando o limite for atingido.

/// Componente visual de alerta para a tela inicial, utilizado para
/// incentivar o upgrade para o plano Pro quando o usuário atinge o limite do plano gratuito.
struct PremiumAlertCard: View {
    
    var action: () -> Void
    
    var body: some View {
        Button(action: action) {
            ZStack {
                LinearGradient(
                    colors: [
                        Color(red: 0.37, green: 0.22, blue: 0.90), // Índigo vibrante
                        Color(red: 0.75, green: 0.35, blue: 0.95)  // Violeta luminoso
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                
                GeometryReader { geo in
                    Circle()
                        .fill(Color.white.opacity(0.15))
                        .frame(width: 120, height: 120)
                        .blur(radius: 20)
                        .position(x: geo.size.width + 10, y: -10)
                    
                    Image(systemName: "crown.fill")
                        .font(.system(size: 140))
                        .foregroundColor(Color.white.opacity(0.1))
                        .position(x: geo.size.width - 20, y: geo.size.height / 2 + 10)
                }
                .clipped()
                VStack(alignment: .leading, spacing: 12) {
                    Text("LIMITE ATINGIDO")
                        .font(.system(size: 10, weight: .bold))
                        .tracking(1)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 5)
                        .background(Color.white.opacity(0.25))
                        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Desbloqueie o Pro")
                            .font(.title3)
                            .fontWeight(.bold)
                        Text("Seu número de pacientes é limitado a 5. ")
                            .font(.subheadline)
                            .foregroundColor(Color.white.opacity(0.9))
                        + Text("Venha para o plano Pro")
                            .font(.subheadline)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                        + Text(" e tenha pacientes ilimitados.")
                            .font(.subheadline)
                            .foregroundColor(Color.white.opacity(0.9))
                    }
                }
                .padding(20)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .frame(height: 152)
            .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
            .shadow(color: Color(red: 0.55, green: 0.25, blue: 0.90).opacity(0.3), radius: 10, x: 0, y: 5)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    PremiumAlertCard(action: {
        print("Abrir Paywall pela Home")
    })
    .padding()
}
