//
//  PendingPaymentCard.swift
//  PsicoFlow
//
//  Created by Kenay on 07/04/26.
//

import SwiftUI

struct PendingPaymentCard: View {
    var pagamento: MonthlyPayment
    var nomePaciente: String
    var iniciais: String
    var mesFormatado: String
    var onPagar: () -> Void
    
    var body: some View {
        VStack(spacing: 16) {
            HStack(alignment: .top) {
                HStack(spacing: 12) {
                    Text(iniciais)
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.red)
                        .frame(width: 40, height: 40)
                        .background(Color.red.opacity(0.1))
                        .clipShape(Circle())
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text(nomePaciente)
                            .font(.system(size: 17, weight: .semibold))
                            .foregroundColor(Color(.darkText))
                        Text("Mensalidade • \(mesFormatado)")
                            .font(.system(size: 13))
                            .foregroundColor(.secondary)
                    }
                }
                Spacer()
                Text(String(format: "R$ %.0f", pagamento.valor))
                    .font(.system(size: 17, weight: .bold))
                    .foregroundColor(.red)
            }
            
            Button(action: onPagar) {
                Text("Registrar Pagamento")
                    .font(.system(size: 15, weight: .semibold))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(Color(.darkText))
                    .foregroundColor(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            }
        }
        .padding(16)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .stroke(Color.red.opacity(0.2), lineWidth: 1)
        )
    }
}
