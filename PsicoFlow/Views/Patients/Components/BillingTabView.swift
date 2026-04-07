//
//  BillingTabView.swift
//  PsicoFlow
//
//  Created by Kenay on 06/04/26.
//

import SwiftUI

struct BillingTabView: View {
    var pagamentos: [MonthlyPayment]
    var onTogglePagamento: (String) -> Void
    
    var body: some View {
        VStack(spacing: 16) {
            
            if pagamentos.isEmpty {
                 // TODO: Ver depois como vai ficar a questao da pessoa gerar quando deve ser pago ou se vai ser automatico do sistema.
                
                Text("Nenhuma fatura registrada.")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .padding(.top, 40)
            } else {
                ForEach(pagamentos) { pagamento in
                    BillingCard(pagamento: pagamento, onToggle: {
                        onTogglePagamento(pagamento.id)
                    })
                }
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 10)
    }
}


