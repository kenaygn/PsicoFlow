//
//  OccupiedSlotCard.swift
//  PsicoFlow
//
//  Created by Kenay on 08/04/26.
//

import SwiftUI

/// Card interativo que representa um slot de tempo ocupado na timeline da agenda.
/// Exibe os detalhes rápidos da sessão (paciente, status, duração e valor) e aciona
/// o modal de ações rápidas ao ser tocado.
struct OccupiedSlotCard: View {
        
    var sessao: Session
    var paciente: Patient
    var onSelect: () -> Void
        
    var body: some View {
        Button(action: onSelect) {
            VStack(alignment: .leading, spacing: 12) {
                
                // MARK: - Identificação e Status
                HStack(alignment: .top) {
                    Text(paciente.nome)
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundColor(Color(.darkText))
                        .multilineTextAlignment(.leading)
                    
                    Spacer()
                    
                    Text(sessao.status.rawValue.capitalized)
                        .font(.system(size: 10, weight: .bold))
                        .textCase(.uppercase)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(corBadge(status: sessao.status).opacity(0.15))
                        .foregroundColor(corBadge(status: sessao.status))
                        .clipShape(Capsule())
                }
                
                // MARK: - Detalhes Operacionais
                HStack(spacing: 16) {
                    HStack(spacing: 4) {
                        Image(systemName: "clock")
                        
                        // Note: O valor "50 min" está fixado. Para escalabilidade, considere
                        // trazer a duração diretamente do modelo `Session` ou do cadastro do `Patient`.
                        Text("50 min")
                    }
                    
                    HStack(spacing: 4) {
                        Image(systemName: "creditcard")
                        Text(String(format: "R$ %.0f", paciente.valor))
                    }
                }
                .font(.system(size: 13, weight: .medium))
                .foregroundColor(.secondary)
            }
            .padding(16)
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .stroke(Color(.systemGray6), lineWidth: 1)
            )
            .shadow(color: Color.black.opacity(0.02), radius: 5, y: 2)
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    // MARK: - Helpers
    
    private func corBadge(status: SessionStatus) -> Color {
        switch status {
        case .realizada: return .gray
        case .agendada: return .teal
        case .adiada: return .orange
        case .cancelada: return .red
        }
    }
}
