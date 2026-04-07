//
//  BillingCard.swift
//  PsicoFlow
//
//  Created by Kenay on 06/04/26.
//

import SwiftUI

// O Cartão Individual da Fatura
struct BillingCard: View {
    var pagamento: MonthlyPayment
    var onToggle: () -> Void
    
    var body: some View {
        VStack(spacing: 16) {
            // Linha Superior: Mês e Valor
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(formatarMesReferencia(pagamento.mesReferencia))
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundColor(Color(.darkText))
                    
                    Text("Mensalidade")
                        .font(.system(size: 13))
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Text(String(format: "R$ %.2f", pagamento.valor).replacingOccurrences(of: ".", with: ","))
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(Color(.darkText))
            }
            
            Divider()
            
            // Linha Inferior: Status e Botão
            HStack {
                // Badge de Status
                HStack(spacing: 4) {
                    Image(systemName: pagamento.pago ? "checkmark.circle.fill" : "exclamationmark.circle.fill")
                    Text(pagamento.statusCobranca)
                }
                .font(.system(size: 11, weight: .bold))
                .foregroundColor(pagamento.pago ? .teal : .red)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(pagamento.pago ? Color.teal.opacity(0.1) : Color.red.opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                
                Spacer()
                
                // Botão de Ação Dinâmico
                Button(action: onToggle) {
                    Text(pagamento.pago ? "Desfazer" : "Registrar Pagamento")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(pagamento.pago ? Color(.darkGray) : .white)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(pagamento.pago ? Color(.systemGray6) : Color(.darkText))
                        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                }
            }
        }
        .padding(16)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
        // Bordinha sutil igual ao Tailwind (border-slate-100 shadow-sm)
        .overlay(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .stroke(Color(.systemGray6), lineWidth: 1)
        )
        .shadow(color: Color.black.opacity(0.03), radius: 8, x: 0, y: 4)
    }
    
    // Função auxiliar para deixar "2026/03" mais bonito: "Março 2026"
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
