//
//  FinancesSuccessCard.swift
//  PsicoFlow
//
//  Created by Kenay on 10/05/26.
//

import SwiftUI

/// Card exibido na tela de Finanças quando
/// não existem pendências de pagamentos em meses anteriores.
struct FinancesSuccessCard: View {
    
    // MARK: - Body
    var body: some View {
        ZStack {
            
            LinearGradient(
                colors: [
                    Color(red: 16/255, green: 185/255, blue: 129/255),
                    Color(red: 5/255, green: 150/255, blue: 105/255)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            
            // MARK: - Elementos Decorativos
            GeometryReader { geo in
                Circle()
                    .fill(Color.white.opacity(0.15))
                    .frame(width: 120, height: 120)
                    .blur(radius: 20)
                    .position(x: geo.size.width + 10, y: -10)
                
                Image(systemName: "sparkles")
                    .font(.system(size: 140))
                    .foregroundColor(Color.white.opacity(0.12))
                    .position(x: geo.size.width - 20, y: geo.size.height / 2 + 10)
            }
            .clipped()
            
            // MARK: - Conteúdo Principal
            VStack(alignment: .leading, spacing: 12) {
                Text("FINANÇAS EM DIA")
                    .font(.system(size: 10, weight: .bold))
                    .tracking(1)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(Color.white.opacity(0.25))
                    .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("Tudo Organizado!")
                        .font(.title3)
                        .fontWeight(.bold)
                    
                    Text("Você não possui pendências de meses anteriores. Seu fluxo de caixa está saudável")
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
        .shadow(color: Color(red: 5/255, green: 150/255, blue: 105/255).opacity(0.3), radius: 10, x: 0, y: 5)
    }
}

#Preview {
    FinancesSuccessCard()
        .padding()
}
