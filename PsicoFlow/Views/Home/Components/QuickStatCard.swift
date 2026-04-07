//
//  QuickStatCard.swift
//  PsicoApp
//
//  Created by Kenay on 02/04/26.
//

import SwiftUI

// O Enum que define a paleta de cores permitida para este card
enum StatCardStyle {
    case primary  // Para as sessões (Teal)
    case danger   // Para o dinheiro a receber (Rose/Red)
    
    var color: Color {
        switch self {
        case .primary: return .teal
        case .danger: return .red // Se criou as cores no Assets, use .statusDanger
        }
    }
}

struct QuickStatCard: View {
    var title: String
    var value: String
    var icon: String
    var style: StatCardStyle
    
    var body: some View {
        // Envolvemos em ZStack para colocar a bolinha decorativa no fundo
        ZStack(alignment: .bottomTrailing) {
            
            // CONTEÚDO PRINCIPAL
            VStack(alignment: .leading, spacing: 0) {
                // Ícone com fundo arredondado
                Image(systemName: icon)
                    .font(.title3)
                    .fontWeight(.semibold)
                    .foregroundColor(style.color)
                    .frame(width: 44, height: 44)
                    .background(style.color.opacity(0.1))
                    .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                
                Spacer(minLength: 16)
                
                // Textos
                VStack(alignment: .leading, spacing: 2) {
                    Text(value)
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(.primary)
                        .tracking(-0.5) // Deixa o número mais imponente
                    
                    Text(title)
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.secondary)
                }
            }
            .padding(16)
            .frame(width: 160, height: 130, alignment: .leading)
            .zIndex(1) // Mantém o texto sempre na frente
            
        }
        .background(Color.white)
        // BOLA DECORATIVA NO CANTO INFERIOR DIREITO
        .overlay(alignment: .bottomTrailing) {
            Circle()
                .fill(style.color.opacity(0.05))
                .frame(width: 90, height: 90)
                .offset(x: 20, y: 20) // Empurra pra fora do card
        }
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .stroke(Color.gray.opacity(0.1), lineWidth: 1)
        )
        .shadow(color: Color.black.opacity(0.03), radius: 8, x: 0, y: 4)
    }
}

// MARK: - Preview
#Preview {
    HStack {
        QuickStatCard(title: "Sessões Hoje", value: "3", icon: "calendar", style: .primary)
        QuickStatCard(title: "A Receber", value: "R$ 450", icon: "exclamationmark.circle", style: .danger)
    }
    .padding()

}
