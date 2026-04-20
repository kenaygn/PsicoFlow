//
//  SingleSessionCard.swift
//  PsicoFlow
//
//  Created by Kenay on 15/04/26.
//

import SwiftUI

struct SingleSessionCard: View {
    let avulsa: Session
    let onEdit: () -> Void
    
    // A Lógica de formatação de data fica encapsulada SÓ onde é necessária!
    private var dataFormatada: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "pt_BR")
        formatter.dateFormat = "dd 'de' MMMM, yyyy"
        return formatter.string(from: avulsa.dataDaSessão)
    }
    
    var body: some View {
        VStack(spacing: 16) {
            
            // --- TOPO DO CARTÃO ---
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 6) {
                    HStack(spacing: 8) {
                        // O ícone e a cor mudam dinamicamente se for adiada
                        Image(systemName:"calendar.badge.clock")
                            .foregroundColor(.orange)
                        
                        Text(avulsa.status == .adiada ? "Sessão Adiada" : "Sessão Avulsa")
                            .font(.system(size: 17, weight: .bold))
                    }
                    
                    // Colocamos a data formatada como o subtítulo
                    Text(dataFormatada)
                        .font(.system(size: 13))
                        .foregroundColor(.secondary)
                }
                Spacer()
                
                // Botão padronizado (Cápsula)
                Button("Editar", action: onEdit)
                    .font(.system(size: 15, weight: .bold))
                    .foregroundColor(.orange)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Color.orange.opacity(0.1))
                    .clipShape(Capsule())
            }
            
            Divider()
            
            // --- BASE DO CARTÃO (INFORMAÇÕES) ---
            HStack {
                // Reaproveitando o InfoItemView que você já criou!
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
        .overlay(RoundedRectangle(cornerRadius: 16, style: .continuous).stroke(Color.gray.opacity(0.1), lineWidth: 1))
        .shadow(color: .black.opacity(0.02), radius: 5, y: 2)
        .padding(.horizontal, 20)
    }
}
