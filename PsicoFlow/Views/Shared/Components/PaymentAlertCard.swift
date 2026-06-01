//
//  PaymentAlertCard.swift
//  PsicoFlow
//
//  Created by Kenay on 09/05/26.
//

import SwiftUI

/// [Componente Global] Card de alerta utilizado para notificar pendências financeiras
/// de meses anteriores, incentivando a regularização do fluxo de caixa.
struct PaymentAlertCard: View {
    
    // MARK: - Propriedades
    var mesReferencia: String // Formato: "MM/yyyy"
    var action: () -> Void
    
    // MARK: - Body
    var body: some View {
        Button(action: action) {
            ZStack {
                
                // MARK: ROXO TOP
                LinearGradient(
                    colors: [
                        Color(red: 129/255, green: 140/255, blue: 248/255), // Indigo 400
                        Color(red: 79/255, green: 70/255, blue: 229/255)    // Indigo 600
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                
                // MARK: VINHO TOP
                //                LinearGradient(
                //                    colors: [
                //                        Color(red: 225/255, green: 29/255, blue: 72/255), // Rose/Ruby 600 (Vibrante)
                //                        Color(red: 159/255, green: 18/255, blue: 57/255)  // Rose/Ruby 800 (Profundo)
                //                    ],
                //                    startPoint: .topLeading,
                //                    endPoint: .bottomTrailing
                //                )
                
                // MARK: - Decorações
                GeometryReader { geo in
                    Circle()
                        .fill(Color.white.opacity(0.15))
                        .frame(width: 120, height: 120)
                        .blur(radius: 20)
                        .position(x: geo.size.width + 10, y: -10)
                    
                    Image(systemName: "dollarsign.circle.fill")
                        .font(.system(size: 140))
                        .foregroundColor(Color.white.opacity(0.1))
                        .position(x: geo.size.width - 20, y: geo.size.height / 2 + 10)
                }
                .clipped()
                
                // MARK: - Conteúdo
                VStack(alignment: .leading, spacing: 12) {
                    Text("PENDÊNCIA FINANCEIRA")
                        .font(.system(size: 10, weight: .bold))
                        .tracking(1)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 5)
                        .background(Color.white.opacity(0.25))
                        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Pagamento Atrasado")
                            .font(.title3)
                            .fontWeight(.bold)
                        
                        Text("Existem pendências de ")
                            .font(.subheadline)
                            .foregroundColor(Color.white.opacity(0.9))
                        + Text("\(mesReferencia)")
                            .font(.subheadline)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                        + Text(" que ainda não foram quitadas. ")
                            .font(.subheadline)
                            .foregroundColor(Color.white.opacity(0.9))
                        + Text("Toque para ver ")
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
            .shadow(color: Color(red: 79/255, green: 70/255, blue: 229/255).opacity(0.3), radius: 10, x: 0, y: 5)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    PaymentAlertCard(mesReferencia: "Abril/2026", action: {})
        .padding()
}
