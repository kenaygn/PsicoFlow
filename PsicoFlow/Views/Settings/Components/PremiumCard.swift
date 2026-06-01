//
//  PremiumCard.swift
//  PsicoFlow
//
//  Created by Kenay on 31/05/26.
//

import SwiftUI

/// Um card de alta conversão, espelhando o design aprovado com imagem flutuante.
struct PremiumCard: View {
    
    @State private var isAnimating: Bool = false
    
    var body: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(red: 0.37, green: 0.22, blue: 0.90), // Índigo vibrante
                    Color(red: 0.75, green: 0.35, blue: 0.95)  // Violeta luminoso
                ]),
                startPoint: isAnimating ? .topLeading : .bottomLeading,
                endPoint: isAnimating ? .bottomTrailing : .topTrailing
            )
            
            GeometryReader { geometry in
                Image(systemName: "crown.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 300)
                    .foregroundColor(.white.opacity(0.1))
                    .rotationEffect(.degrees(-30))
                    .position(x: geometry.size.width * 0.80, y: geometry.size.height * 0.7)
            }
            .clipped()
            
            VStack(alignment: .leading, spacing: 16) {
                VStack(alignment: .leading, spacing: 12) {
                    Text("OFERTA ESPECIAL")
                        .font(.caption)
                        .fontWeight(.bold)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Color.white.opacity(0.25))
                        .foregroundColor(.white)
                        .clipShape(Capsule())
                    
                    Text("PsicoFlow Pro")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                }
                
                VStack(spacing: -4) {
                    Text("de R$ 50,00")
                        .font(.subheadline)
                        .strikethrough()
                        .foregroundColor(.white.opacity(0.7))
                    
                    HStack(alignment: .firstTextBaseline, spacing: 4) {
                        Text("Por")
                            .font(.headline)
                            .foregroundColor(.white.opacity(0.9))
                        
                        Text("R$ 29,90")
                            .font(.system(size: 46, weight: .black, design: .default))
                            .foregroundColor(.white)
                        
                        Text("/mês")
                            .font(.subheadline)
                            .foregroundColor(.white.opacity(0.9))
                    }
                }
                .frame(maxWidth: .infinity, alignment: .center)
                
                Text("Tenha controle total da sua agenda com pacientes ilimitados.")
                    .font(.callout)
                    .fontWeight(.medium)
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.horizontal, 8)
                
                Button(action: {
                    print("Abrir Paywall")
                }) {
                    Text("Aproveitar Desconto")
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundColor(Color(red: 0.65, green: 0.30, blue: 0.92)) // Roxo combinando
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(Color.white)
                        .cornerRadius(12)
                }
            }
            .padding(24)
        }
        .cornerRadius(20)
        .shadow(color: Color(red: 0.55, green: 0.25, blue: 0.90).opacity(0.3), radius: 15, x: 0, y: 8)
        .overlay(
            Image("premium")
                .resizable()
                .scaledToFit()
                .frame(width: 180)
                .offset(x: 5, y: -25),
            alignment: .topTrailing
        )
        .padding(.top, 16)
        // Animação de Fundo
        .onAppear {
            withAnimation(.easeInOut(duration: 3.0).repeatForever(autoreverses: true)) {
                isAnimating = true
            }
        }
    }
}

#Preview {
    PremiumCard()
}
