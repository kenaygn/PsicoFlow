//
//  FixedSessionCard.swift
//  PsicoFlow
//
//  Created by Kenay on 15/04/26.
//

import SwiftUI

struct FixedSessionCard: View {
    let fixa: FixedSession
    let diaDaSemanaTexto: String
    let onEdit: () -> Void
    
    var body: some View {
        VStack(spacing: 16) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 6) {
                    HStack(spacing: 8) {
                        Image(systemName: "repeat.circle.fill")
                            .foregroundColor(.teal)
                        Text("Sessão Semanal")
                            .font(.system(size: 17, weight: .bold))
                    }
                    
                    Text("Cria as sessões automaticamente toda semana neste mesmo dia e horário.")
                        .font(.system(size: 13))
                        .foregroundColor(.secondary)
                }
                Spacer()
                
                Button("Editar", action: onEdit)
                    .font(.system(size: 15, weight: .bold))
                    .foregroundColor(.teal)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Color.teal.opacity(0.1))
                    .clipShape(Capsule())
            }
            
            Divider()
            
            HStack {
                InfoItemView(icon: "calendar", title: "Dia", value: diaDaSemanaTexto)
                Spacer()
                InfoItemView(icon: "clock", title: "Horário", value: fixa.horaInicio)
                Spacer()
                InfoItemView(icon: "video", title: "Formato", value: fixa.modalidade.rawValue.capitalized)
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

