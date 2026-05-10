//
//  QuickStatCard.swift
//  PsicoApp
//
//  Created by Kenay on 02/04/26.
//

import SwiftUI

/// Define a paleta de cores em gradiente para os cards de estatísticas rápidas.
enum StatCardStyle {
    case primary
    case danger
    case financeSuccess
    
    // Retorna um array de cores para formar o gradiente
    var gradientColors: [Color] {
        switch self {
        case .primary:
            return [
                Color(red: 0, green: 0.76, blue: 0.76),
                Color(red: 0, green: 0.63, blue: 0.62)
            ]
        case .danger:
            return [
                // Um vermelho muito mais leve (Tom de Rose/Coral) para não agredir os olhos
                Color(red: 251/255, green: 113/255, blue: 133/255), // Rose 400
                Color(red: 244/255, green: 63/255, blue: 94/255)    // Rose 500
            ]
        case .financeSuccess:
            return [
                Color(red: 16/255, green: 185/255, blue: 129/255),
                Color(red: 5/255, green: 150/255, blue: 105/255)
            ]
        }
    }
    
    // Cor base para a sombra do cartão
    var shadowColor: Color {
        switch self {
        case .primary: return Color(red: 20/255, green: 184/255, blue: 166/255)
        case .danger: return Color(red: 244/255, green: 63/255, blue: 94/255)
        case .financeSuccess: return Color(red: 5/255, green: 150/255, blue: 105/255)
        }
    }
}

/// Card de estatística rápida utilizado no painel principal (Dashboard).
/// Utiliza gradientes, Glassmorphism e marca d'água para um visual premium.
struct QuickStatCard: View {
        
    var title: String
    var value: String
    var icon: String
    var style: StatCardStyle
        
    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            
            // MARK: - Background Gradient
            LinearGradient(
                colors: style.gradientColors,
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            
            // MARK: - Marca d'água (Watermark)
            GeometryReader { geo in
                Image(systemName: icon)
                    .font(.system(size: 128))
                    .foregroundColor(Color.white.opacity(0.15))
                    .rotationEffect(.degrees(10))
                    .position(x: geo.size.width - 30, y: geo.size.height - 30)
            }
            .clipped()
            
            // MARK: - Conteúdo Principal
            VStack(alignment: .leading, spacing: 0) {
                
                // Caixa do Ícone (Glassmorphism)
                Image(systemName: icon)
                    .font(.title2)
                    .fontWeight(.medium)
                    .foregroundColor(.white)
                    .frame(width: 36, height: 36)
                    .background(Color.white.opacity(0.2))
                    .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                            .stroke(Color.white.opacity(0.4), lineWidth: 1)
                    )
                
                Spacer(minLength: 16)
                
                // Textos
                VStack(alignment: .leading, spacing: 2) {
                    Text(value)
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(.white)
                        .tracking(-0.5)
                    
                    Text(title)
                        .font(.subheadline)
                        .fontWeight(.bold)
                        .foregroundColor(Color.white.opacity(0.9))
                }
            }
            .padding()
            .frame(width: 160, height: 130, alignment: .leading)
            .zIndex(1)
            
        }
        .frame(width: 160)
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
        // Sombra agora utiliza a cor base do gradiente para maior naturalidade
        .shadow(color: style.shadowColor.opacity(0.3), radius: 10, x: 0, y: 5)
    }
}

#Preview {
    HStack {
        QuickStatCard(title: "Sessões Hoje", value: "3", icon: "calendar", style: .primary)
        
        QuickStatCard(title: "A Receber", value: "R$ 700", icon: "exclamationmark.circle", style: .danger)
    }
    .padding()
}
