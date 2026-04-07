//
//  EvolutionCard.swift
//  PsicoFlow
//
//  Created by Kenay on 04/04/26.
//

import SwiftUI

// MARK: - 1. O Componente do Cartão Individual
struct EvolutionCardView: View {
    let evolucao: Evolution
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header: Ícone de Calendário e Data
            HStack {
                HStack(spacing: 6) {
                    Image(systemName: "calendar")
                        .font(.system(size: 14))
                        .foregroundColor(.teal)
                    
                    Text(formatarData(evolucao.data))
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(Color(.darkGray))
                }
                
                Spacer()
                
                // Se no futuro você adicionar tipos (como o áudio do React), o Badge entraria aqui
                Text("TEXTO")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundColor(.teal)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.teal.opacity(0.1))
                    .clipShape(Capsule())
            }
            
            // Corpo da Nota Clínica
            Text(evolucao.conteudo)
                .font(.system(size: 15))
                .foregroundColor(Color(.darkGray))
                .lineSpacing(4) // Dá um respiro melhor para textos longos
        }
        .padding(20)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
        .shadow(color: Color.black.opacity(0.03), radius: 5, x: 0, y: 2)
        .overlay(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .stroke(Color.gray.opacity(0.1), lineWidth: 1)
        )
    }
    
    // Função auxiliar para formatar a data estilo iOS (ex: 22/03/2026)
    private func formatarData(_ data: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/yyyy"
        return formatter.string(from: data)
    }
}
