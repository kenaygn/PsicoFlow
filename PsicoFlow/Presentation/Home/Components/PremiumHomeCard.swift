//
//  PremiumHomeCard.swift
//  PsicoFlow
//
//  Created by Kenay on 22/07/26.
//

import SwiftUI

/// Card de promoção do plano Premium adaptado para o carrossel da HomeView.
struct PremiumHomeCard: View {
    
    var limiteAtingido: Bool
    var action: () -> Void
    
    @State private var isAnimating: Bool = false
    
    var body: some View {
        Button(action: {
            action()
        }) {
            ZStack(alignment: .leading) {
                
                // MARK: - Background Animado
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color(red: 0.37, green: 0.22, blue: 0.90),
                        Color(red: 0.75, green: 0.35, blue: 0.95)
                    ]),
                    startPoint: isAnimating ? .topLeading : .bottomLeading,
                    endPoint: isAnimating ? .bottomTrailing : .topTrailing
                )
                
                // MARK: - Decorações
                GeometryReader { geo in
                    Circle()
                        .fill(Color.white.opacity(0.1))
                        .frame(width: 120, height: 120)
                        .blur(radius: 20)
                        .position(x: geo.size.width + 10, y: -10)
                    
                    Image(systemName: "crown.fill")
                        .font(.system(size: 140))
                        .foregroundColor(Color.white.opacity(0.15))
                        .rotationEffect(.degrees(-20))
                        .position(x: geo.size.width - 20, y: geo.size.height / 2 + 10)
                }
                .clipped()
                
                // MARK: - Conteúdo Dinâmico
                VStack(alignment: .leading, spacing: 12) {
                    
                    Text("OFERTA ESPECIAL")
                        .font(.system(size: 10, weight: .bold))
                        .tracking(1)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 5)
                        .background(Color.white.opacity(0.25))
                        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Conheça o Psyes Pro")
                            .font(.title3)
                            .fontWeight(.bold)
                        
                        if limiteAtingido {
                            Text("Você atingiu a cota do plano Free. ")
                                .font(.subheadline)
                                .foregroundColor(Color.white.opacity(0.9))
                            + Text("Assine agora ")
                                .font(.subheadline)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                            + Text("para pacientes ilimitados.")
                                .font(.subheadline)
                                .foregroundColor(Color.white.opacity(0.9))
                        } else {
                            Text("Assuma o controle total da agenda com ")
                                .font(.subheadline)
                                .foregroundColor(Color.white.opacity(0.9))
                            + Text("pacientes ilimitados ")
                                .font(.subheadline)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                            + Text("e 1 mês grátis.")
                                .font(.subheadline)
                                .foregroundColor(Color.white.opacity(0.9))
                        }
                    }
                    .padding(.bottom, 4)
                }
                .padding(20)
                .foregroundColor(.white)
            }
            .frame(height: 152)
            .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
            .shadow(color: Color(red: 0.55, green: 0.25, blue: 0.90).opacity(0.3), radius: 15, x: 0, y: 8)
        }
        .buttonStyle(PlainButtonStyle()) // Garante que o botão não mude de cor ao ser tocado
        .onAppear {
            withAnimation(.easeInOut(duration: 3.0).repeatForever(autoreverses: true)) {
                isAnimating = true
            }
        }
    }
}

#Preview {
    VStack(spacing: 20) {
        PremiumHomeCard(limiteAtingido: false, action: {})
        PremiumHomeCard(limiteAtingido: true, action: {})
    }
    .padding()
}
