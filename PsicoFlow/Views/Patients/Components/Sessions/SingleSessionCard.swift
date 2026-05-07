//
//  SingleSessionCard.swift
//  PsicoFlow
//
//  Created by Kenay on 15/04/26.
//

import SwiftUI

/// Componente visual que exibe os detalhes de uma sessão única (avulsa ou adiada).
struct SingleSessionCard: View {
    
    let avulsa: Session
    let onEdit: () -> Void
        
    /// - Note: Considere extrair este DateFormatter para uma constante estática
    ///         para evitar a recriação da instância a cada renderização da View,
    ///         especialmente se este card for exibido em listas longas.
    private var dataFormatada: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "pt_BR")
        formatter.dateFormat = "dd 'de' MMMM, yyyy"
        return formatter.string(from: avulsa.dataDaSessão)
    }
        
    var body: some View {
        VStack(spacing: 16) {
            
            // MARK: - Cabeçalho
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 6) {
                    HStack(spacing: 8) {
                        Image(systemName: "calendar.badge.clock")
                            .foregroundColor(.orange)
                        
                        Text(avulsa.status == .adiada ? "Sessão Adiada" : "Sessão Avulsa")
                            .font(.system(size: 17, weight: .bold))
                    }
                    
                    Text(dataFormatada)
                        .font(.system(size: 13))
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Button("Editar", action: onEdit)
                    .font(.system(size: 15, weight: .bold))
                    .foregroundColor(.orange)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Color.orange.opacity(0.1))
                    .clipShape(Capsule())
            }
            
            Divider()
            
            // MARK: - Detalhes Operacionais
            HStack {
                InfoItemView(icon: "circle.fill", title: "Status", value: avulsa.status.rawValue.capitalized, isDark: false)
                Spacer()
                InfoItemView(icon: "clock", title: "Horário", value: avulsa.horaInicio, isDark: false)
                Spacer()
                InfoItemView(icon: "video", title: "Formato", value: avulsa.modalidade.rawValue.capitalized, isDark: false)
            }
        }
        .padding(16)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(Color.gray.opacity(0.1), lineWidth: 1)
        )
        .shadow(color: .black.opacity(0.02), radius: 5, y: 2)
        .padding(.horizontal, 20)
    }
}
