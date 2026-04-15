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
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(dataFormatada)
                    .font(.system(size: 16, weight: .bold))
                
                HStack(spacing: 8) {
                    Label(avulsa.horaInicio, systemImage: "clock")
                    Text("•")
                    Label(avulsa.status.rawValue.capitalized, systemImage: "circle.fill")
                        .foregroundColor(avulsa.status == .adiada ? .orange : .teal)
                }
                .font(.system(size: 13, weight: .medium))
                .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Button(action: onEdit) {
                Image(systemName: "pencil")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.teal)
                    .frame(width: 40, height: 40)
                    .background(Color(.systemGray6))
                    .clipShape(Circle())
            }
        }
        .padding(16)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: 16, style: .continuous).stroke(Color.gray.opacity(0.1), lineWidth: 1))
        .padding(.horizontal, 20)
    }
}
