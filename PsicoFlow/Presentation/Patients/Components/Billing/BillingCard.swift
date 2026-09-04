//
//  BillingCard.swift
//  PsicoFlow
//
//  Created by Kenay on 06/04/26.
//

import SwiftUI

/// Componente visual que exibe o resumo financeiro mensal de um paciente.
/// Inclui a formatação de valores e um atalho de ação rápida para baixar ou estornar o pagamento.
struct BillingCard: View {
    
    // MARK: - Properties
    
    var pagamento: MonthlyPayment
    var onToggle: () -> Void
    
    // MARK: - Body
    
    var body: some View {
        VStack(spacing: 16) {
            
            // MARK: - Cabeçalho (Mês e Valor)
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(formatarMesReferencia(pagamento.referenceMonth))
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundColor(Color(.darkText))
                    
                    Text("Mensalidade")
                        .font(.system(size: 13))
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                // Note: A substituição do ponto por vírgula atende rapidamente ao padrão BRL.
                // Para escalar a aplicação para outras moedas no futuro, o ideal será migrar para um NumberFormatter.
                Text(String(format: "R$ %.2f", pagamento.value).replacingOccurrences(of: ".", with: ","))
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(Color(.darkText))
            }
            
            Divider()
            
            // MARK: - Status e Ações
            HStack {
                HStack(spacing: 4) {
                    Image(systemName: pagamento.paid ? "checkmark.circle.fill" : "exclamationmark.circle.fill")
                    Text(pagamento.billingStatus)
                }
                .font(.system(size: 11, weight: .bold))
                .foregroundColor(pagamento.paid ? .teal : .red)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(pagamento.paid ? Color.teal.opacity(0.1) : Color.red.opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                
                Spacer()
                
                Button(action: onToggle) {
                    Text(pagamento.paid ? "Desfazer" : "Registrar Pagamento")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(pagamento.paid ? Color(.darkGray) : .white)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(pagamento.paid ? Color(.systemGray6) : Color(.darkText))
                        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                }
            }
        }
        .padding(16)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .stroke(Color(.systemGray6), lineWidth: 1)
        )
        .shadow(color: Color.black.opacity(0.03), radius: 8, x: 0, y: 4)
    }
    
    // MARK: - Helpers
    
    /// Converte a string de referência "YYYY/MM" para uma leitura amigável (ex: "Março 2026").
    private func formatarMesReferencia(_ mesAno: String) -> String {
        let partes = mesAno.split(separator: "/")
        guard partes.count == 2, let mesStr = partes.last, let mesInt = Int(mesStr) else { return mesAno }
        
        let meses = ["Janeiro", "Fevereiro", "Março", "Abril", "Maio", "Junho", "Julho", "Agosto", "Setembro", "Outubro", "Novembro", "Dezembro"]
        
        if mesInt >= 1 && mesInt <= 12 {
            return "\(meses[mesInt - 1]) \(partes.first!)"
        }
        return mesAno
    }
}
