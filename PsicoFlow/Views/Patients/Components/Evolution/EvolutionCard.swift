//
//  EvolutionCardView.swift
//  PsicoFlow
//
//  Created by Kenay on 04/04/26.
//

import SwiftUI

/// Componente visual que exibe um registro individual do prontuário ou evolução clínica.
struct EvolutionCardView: View {
        
    let evolucao: Evolution
    
    /// - Note: Para listas com milhares de evoluções, considere mover este
    ///         DateFormatter para uma constante estática para evitar recriação.
    private var dataFormatada: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/yyyy"
        return formatter.string(from: evolucao.data)
    }
        
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            
            // MARK: - Cabeçalho
            HStack {
                HStack(spacing: 6) {
                    Image(systemName: "calendar")
                        .font(.system(size: 14))
                        .foregroundColor(.teal)
                    
                    Text(dataFormatada)
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(Color(.darkGray))
                }
                
                Spacer()
                
                // TODO: Tornar este Badge dinâmico para suportar futuras mídias (ex: Áudio, Anexos).
                Text("TEXTO")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundColor(.teal)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.teal.opacity(0.1))
                    .clipShape(Capsule())
            }
            
            // MARK: - Conteúdo Clínico
            Text(evolucao.conteudo)
                .font(.system(size: 15))
                .foregroundColor(Color(.darkGray))
                .lineSpacing(4)
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
}
