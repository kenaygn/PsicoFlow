//
//  FinanceStatCard.swift
//  PsicoFlow
//
//  Created by Kenay on 07/04/26.
//

import SwiftUI

/// Componente visual que exibe um totalizador financeiro no painel de finanças.
struct FinanceStatCard: View {
        
    var titulo: String
    var valor: String
    var icone: String
    var corTema: Color
    
    // MARK: - Lógica de Cores Dinâmicas
    private var gradientColors: [Color] {
        if corTema == .teal {
            return [
                .teal,
                Color(red: 0.1, green: 0.64, blue: 0.66)
            ]
        } else if corTema == .red {
            return [
                Color(red: 251/255, green: 113/255, blue: 133/255), 
                Color(red: 244/255, green: 63/255, blue: 94/255)
            ]
        } else {
            return [
                Color(red: 16/255, green: 185/255, blue: 129/255),
                Color(red: 5/255, green: 150/255, blue: 105/255)
            ]
        }
    }
    
    private var shadowColor: Color {
        if corTema == .teal {
            return Color(red: 0, green: 0.63, blue: 0.62)
        } else if corTema == .red{
            return Color(red: 244/255, green: 63/255, blue: 94/255)
        } else {
            return Color(red: 5/255, green: 150/255, blue: 105/255)
        }
    }
        
    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            
            // MARK: - Background Gradient
            LinearGradient(
                colors: gradientColors,
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            
            // MARK: - Marca d'água (Watermark)
            GeometryReader { geo in
                Image(systemName: icone)
                    .font(.system(size: 90))
                    .foregroundColor(Color.white.opacity(0.15))
                    .rotationEffect(.degrees(10))
                    .position(x: geo.size.width - 20, y: geo.size.height - 20)
            }
            .clipped()
            
            // MARK: - Conteúdo Principal
            VStack(alignment: .leading, spacing: 12) {
                
                HStack(spacing: 6) {
                    Image(systemName: icone)
                        .foregroundColor(.white)
                        .font(.system(size: 14, weight: .semibold))
                    
                    Text(titulo)
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(Color.white.opacity(0.9))
                }
                
                Text(valor)
                    .font(.system(size: 26, weight: .bold))
                    .foregroundColor(.white)
                    .lineLimit(1)
                    .minimumScaleFactor(0.5)
            }
            .padding(20)
            .frame(height: 100)
            .frame(maxWidth: .infinity, alignment: .leading)
            .zIndex(1)
        }
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
        .shadow(color: shadowColor.opacity(0.3), radius: 10, x: 0, y: 5)
    }
}

#Preview {
    HStack(spacing: 16) {
        FinanceStatCard(
            titulo: "Recebido",
            valor: "R$ 4.500",
            icone: "checkmark.circle.fill",
            corTema: .teal
        )
        
        FinanceStatCard(
            titulo: "A Receber",
            valor: "R$ 0",
            icone: "exclamationmark.circle.fill",
            corTema: .red
        )
    }
    .padding()
}
