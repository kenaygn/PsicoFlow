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
        
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            
            // MARK: - Cabeçalho
            HStack(spacing: 6) {
                Image(systemName: icone)
                    .foregroundColor(corTema)
                
                Text(titulo)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(.secondary)
            }
            
            // MARK: - Valor Principal
            Text(valor)
                .font(.system(size: 26, weight: .bold))
                .foregroundColor(Color(.darkText))
                .lineLimit(1)
                .minimumScaleFactor(0.5)
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.white)
        
        .overlay {
            Circle()
                .fill(corTema.opacity(0.05))
                .frame(width: 90, height: 90)
                .offset(x: 75, y: 30)
        }
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .stroke(corTema.opacity(0.3), lineWidth: 1)
        )
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
            valor: "R$ 1.000",
            icone: "exclamationmark.circle.fill",
            corTema: .red
        )
    }
    .padding()
}
