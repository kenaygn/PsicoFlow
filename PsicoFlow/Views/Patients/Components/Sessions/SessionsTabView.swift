//
//  SessionsTabView.swift
//  PsicoFlow
//
//  Created by Kenay on 15/04/26.
//

import SwiftUI

struct SessionsTabView: View {
    let sessoesFixas: [FixedSession]
    let sessoesAvulsas: [Session]
    let converterDia: (Int) -> String
    
    let onEditFixed: (FixedSession) -> Void
    let onEditAvulsa: (Session) -> Void
    
    var body: some View {
        VStack(spacing: 32) {
            //Sessões Recorrentes
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
            //Sessões Avulsas
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



