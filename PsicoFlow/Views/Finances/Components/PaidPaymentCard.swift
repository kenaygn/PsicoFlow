//
//  PaidPaymentCard.swift
//  PsicoFlow
//
//  Created by Kenay on 07/04/26.
//

import SwiftUI

/// Card visual compacto que exibe uma mensalidade já quitada.
struct PaidPaymentCard: View {
        
    var pagamento: MonthlyPayment
    var nomePaciente: String
    var mesFormatado: String
    var onDesfazer: () -> Void
        
    var body: some View {
        HStack(alignment: .center) {
            
            // MARK: - Status e Paciente
            HStack(spacing: 12) {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 24))
                    .foregroundColor(.teal)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(nomePaciente)
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundColor(Color(.darkText))
                    
                    Text("Pago ref. \(mesFormatado)")
                        .font(.system(size: 13))
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
            
            // MARK: - Valor e Ação
            VStack(alignment: .trailing, spacing: 4) {
                
                // Note: Para projetos focados em iOS 15+, considere substituir
                // a formatação C-style nativa por: pagamento.valor.formatted(.currency(code: "BRL"))
                Text(String(format: "R$ %.0f", pagamento.value))
                    .font(.system(size: 17, weight: .bold))
                    .foregroundColor(.teal)
                
                Button(action: onDesfazer) {
                    Text("Desfazer")
                        .font(.system(size: 11, weight: .semibold))
                        .underline()
                        .foregroundColor(.gray)
                }
            }
        }
        .padding(16)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .stroke(Color(.systemGray6), lineWidth: 1)
        )
    }
}
