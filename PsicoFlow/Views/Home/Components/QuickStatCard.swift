//
//  QuickStatCard.swift
//  PsicoApp
//
//  Created by Kenay on 02/04/26.
//

import SwiftUI

/// Define a paleta de cores para os cards de estatísticas rápidas.
enum StatCardStyle {
    case primary
    case danger
    
    var color: Color {
        switch self {
        case .primary: return .teal
        case .danger: return .red
        }
    }
}

/// Card de estatística rápida utilizado no painel principal (Dashboard).
/// Ideal para exibir métricas-chave (KPIs) de forma isolada, com suporte a estilos semânticos.
struct QuickStatCard: View {
        
    var title: String
    var value: String
    var icon: String
    var style: StatCardStyle
        
    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            
            // MARK: - Conteúdo Principal
            VStack(alignment: .leading, spacing: 0) {
                Image(systemName: icon)
                    .font(.title3)
                    .fontWeight(.semibold)
                    .foregroundColor(style.color)
                    .frame(width: 44, height: 44)
                    .background(style.color.opacity(0.1))
                    .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                
                Spacer(minLength: 16)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(value)
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(.primary)
                        .tracking(-0.5)
                    
                    Text(title)
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.secondary)
                }
            }
            .padding(16)
            .frame(width: 160, height: 130, alignment: .leading)
            .zIndex(1)
            
        }
        .background(Color.white)
        // MARK: - Elementos Decorativos
        .overlay(alignment: .bottomTrailing) {
            Circle()
                .fill(style.color.opacity(0.05))
                .frame(width: 90, height: 90)
                .offset(x: 20, y: 20)
        }
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .stroke(Color.gray.opacity(0.1), lineWidth: 1)
        )
        .shadow(color: Color.black.opacity(0.03), radius: 8, x: 0, y: 4)
    }
}

#Preview {
    HStack {
        QuickStatCard(title: "Sessões Hoje", value: "3", icon: "calendar", style: .primary)
        QuickStatCard(title: "A Receber", value: "R$ 450", icon: "exclamationmark.circle", style: .danger)
    }
    .padding()
}
