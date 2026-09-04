//
//  BillingTabView.swift
//  PsicoFlow
//
//  Created by Kenay on 06/04/26.
//

import SwiftUI

/// Aba responsável pela exibição e gestão do histórico financeiro do paciente.
///
/// - Note: View puramente visual (Stateless). O controle de estado dos pagamentos
///         é gerenciado pela ViewModel da tela pai e injetado via closure.
struct BillingTabView: View {
        
    var pagamentos: [MonthlyPayment]
    var onTogglePagamento: (String) -> Void
        
    var body: some View {
        VStack(spacing: 16) {
            
            // MARK: - Estado Vazio e Lista de Faturas
            if pagamentos.isEmpty {
                
                // TODO: Definir arquitetura de geração de mensalidades.
                // Pendência: Estabelecer se o fluxo de cobrança será processado automaticamente
                // pelo sistema (ex: rotina de background baseada no contrato) ou se exigirá
                // o acionamento manual do psicólogo na interface.
                Text("Nenhuma fatura registrada.")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .padding(.top, 40)
                    
            } else {
                ForEach(pagamentos) { pagamento in
                    BillingCard(
                        pagamento: pagamento,
                        onToggle: {
                            onTogglePagamento(pagamento.id)
                        }
                    )
                }
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 10)
    }
}
