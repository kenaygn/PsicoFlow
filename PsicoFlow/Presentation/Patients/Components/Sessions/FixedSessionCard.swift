//
//  FixedSessionCard.swift
//  PsicoFlow
//
//  Created by Kenay on 15/04/26.
//

import SwiftUI

/// Componente visual destacado que representa o contrato de recorrência (Sessão Fixa) de um paciente.
/// Exibe as regras base que o sistema utiliza para automatizar a agenda.
struct FixedSessionCard: View {
        
    let fixa: FixedSession
    let diaDaSemanaTexto: String
    let onEdit: () -> Void
    
    private var corFundoRosa: LinearGradient {
        LinearGradient(
            colors: [
                Color(red: 0.98, green: 0.45, blue: 0.50), 
                Color(red: 0.89, green: 0.25, blue: 0.35)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
        
    var body: some View {
        VStack(spacing: 16) {
            
            // MARK: - Cabeçalho
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 6) {
                    HStack(spacing: 8) {
                        Image(systemName: "repeat.circle.fill")
                            .foregroundColor(.white)
                        
                        Text("Sessão Semanal")
                            .font(.system(size: 17, weight: .bold))
                            .foregroundColor(.white)
                    }
                    
                    Text("Cria as sessões automaticamente toda semana neste mesmo dia e horário.")
                        .font(.system(size: 13))
                        .foregroundColor(.white.opacity(0.85))
                }
                
                Spacer()
                
                Button("Editar", action: onEdit)
                    .font(.system(size: 15, weight: .bold))
                    .foregroundColor(.white)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Color.white.opacity(0.25))
                    .clipShape(Capsule())
            }
            
            Divider()
                .background(Color.white)
            
            // MARK: - Detalhes da Regra
            HStack {
                InfoItemView(icon: "calendar", title: "Dia", value: diaDaSemanaTexto, isDark: true)
                Spacer()
                InfoItemView(icon: "clock", title: "Horário", value: fixa.startTime, isDark: true)
                Spacer()
                InfoItemView(icon: "video", title: "Formato", value: fixa.modality.rawValue.capitalized, isDark: true)
            }
        }
        .padding(16)
        .background(corFundoRosa)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .shadow(color: Color.black.opacity(0.12), radius: 8, y: 4)
        .padding(.horizontal, 20)
    }
}
