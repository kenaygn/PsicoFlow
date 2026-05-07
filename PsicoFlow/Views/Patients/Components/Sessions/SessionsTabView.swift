//
//  SessionsTabView.swift
//  PsicoFlow
//
//  Created by Kenay on 15/04/26.
//

import SwiftUI

/// Aba responsável por listar a agenda específica de um paciente.
///
/// - Note: Esta é uma "Stateless View". Toda a lógica de negócio, conversão de datas
///         e gerenciamento de estado é injetada via propriedades e closures pela View Pai.
struct SessionsTabView: View {
        
    let sessoesFixas: [FixedSession]
    let sessoesAvulsas: [Session]
    
    /// Closure para delegar a conversão do número do dia (1-7) para texto localizado.
    let converterDia: (Int) -> String
    
    let onEditFixed: (FixedSession) -> Void
    let onEditAvulsa: (Session) -> Void
        
    var body: some View {
        VStack(spacing: 32) {
            
            // MARK: - Sessões Recorrentes
            VStack(alignment: .leading, spacing: 16) {
                Text("Sessões Recorrentes")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.secondary)
                    .textCase(.uppercase)
                    .padding(.horizontal, 20)
                
                if sessoesFixas.isEmpty {
                    Text("Nenhuma sessão fixa configurada.")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .padding(.horizontal, 20)
                } else {
                    ForEach(sessoesFixas, id: \.id) { fixa in
                        FixedSessionCard(
                            fixa: fixa,
                            diaDaSemanaTexto: converterDia(fixa.diaDaSemana),
                            onEdit: { onEditFixed(fixa) }
                        )
                    }
                }
            }
            
            // MARK: - Sessões Avulsas e Adiadas
            VStack(alignment: .leading, spacing: 16) {
                Text("Sessões Avulsas e Adiadas")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.secondary)
                    .textCase(.uppercase)
                    .padding(.horizontal, 20)
                
                if sessoesAvulsas.isEmpty {
                    Text("Nenhuma sessão avulsa programada para o futuro.")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .padding(.horizontal, 20)
                } else {
                    ForEach(sessoesAvulsas, id: \.id) { avulsa in
                        SingleSessionCard(
                            avulsa: avulsa,
                            onEdit: { onEditAvulsa(avulsa) }
                        )
                    }
                }
            }
        }
        .padding(.vertical, 16)
    }
}
