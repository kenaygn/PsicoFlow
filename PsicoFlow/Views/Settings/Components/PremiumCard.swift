//
//  PremiumCard.swift
//  PsicoFlow
//
//  Created by Kenay on 31/05/26.
//

import SwiftUI

/// Um card redesenhado focado na elegância do sistema iOS nativo.
struct PremiumCard: View {
    
    @State private var isAnimating: Bool = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            
            // 1. Cabeçalho com Ícone e Badge de Oferta
            HStack {
                Image(systemName: "crown.fill")
                    .font(.title2)
                    .foregroundColor(.white)
                
                Spacer()
                
                Text("OFERTA ESPECIAL")
                    .font(.caption2)
                    .fontWeight(.bold)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(Color.white.opacity(0.25))
                // A cor do texto combina com o fundo para manter a harmonia
                    .foregroundColor(Color(UIColor.white))
                    .clipShape(Capsule())
            }
            
            // 2. Títulos e Proposta de Valor
            VStack(alignment: .leading, spacing: 6) {
                Text("PsicoFlow Pro")
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                
                Text("Controle total do consultório com faturamento e relatórios automáticos.")
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.9))
                    .fixedSize(horizontal: false, vertical: true)
            }
            
            // 3. Área de Preço Chamativa (Ancoragem)
            HStack(alignment: .bottom, spacing: 8) {
                Text("De R$ 50,00")
                    .font(.subheadline)
                    .strikethrough() // Risco no preço original
                    .foregroundColor(.white.opacity(0.7))
                
                Text("Por R$ 29,90")
                    .font(.title2)
                    .fontWeight(.black)
                    .foregroundColor(.white)
                
                Text("/mês")
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.9))
                    .padding(.bottom, 4)
            }
            .padding(.top, 4)
            
            // 4. Botão de Ação (Call to Action)
            Button(action: {
                print("Abrir Paywall")
            }) {
                Text("Aproveitar Desconto")
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .foregroundColor(Color(red: 0.75, green: 0.35, blue: 0.95))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(Color.white)
                    .cornerRadius(10)
            }
            .padding(.top, 4)
        }
        .padding(20)
        .frame(maxWidth: .infinity)
        .background(
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(red: 0.37, green: 0.22, blue: 0.90), // Índigo vibrante (topo esquerdo)
                    Color(red: 0.75, green: 0.35, blue: 0.95)  // Violeta luminoso (fundo direito)
                ]),
                startPoint: isAnimating ? .topLeading : .bottomLeading,
                endPoint: isAnimating ? .bottomTrailing : .topTrailing
            )
        )
        .cornerRadius(16)
        .shadow(color: Color(red: 0.55, green: 0.25, blue: 0.90).opacity(0.15), radius: 10, x: 0, y: 5)
        .onAppear {
            withAnimation(.easeInOut(duration: 3.0).repeatForever(autoreverses: true)) {
                isAnimating = true
            }
        }
    }
}
