//
//  EmptySlotCard.swift
//  PsicoFlow
//
//  Created by Kenay on 08/04/26.
//

import SwiftUI

/// Componente visual de *placeholder* que representa um horário livre na agenda.
struct EmptySlotCard: View {
        
    var onAdd: () -> Void
        
    var body: some View {
        Button(action: onAdd) {
            HStack {
                Text("Horário livre")
                    .font(.system(size: 15, weight: .medium))
                    .foregroundColor(Color(.systemGray3))
                
                Spacer()
                
                Image(systemName: "plus")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.teal)
                    .frame(width: 32, height: 32)
                    .background(Color.white)
                    .clipShape(Circle())
                    .shadow(color: Color.black.opacity(0.05), radius: 3)
                    .overlay(
                        Circle().stroke(Color(.systemGray5), lineWidth: 1)
                    )
            }
            .frame(height: 64)
            .padding(.horizontal, 16)
            .background(Color.teal.opacity(0.03))
            .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .stroke(style: StrokeStyle(lineWidth: 2, dash: [6]))
                    .foregroundColor(Color(.systemGray4).opacity(0.5))
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}
