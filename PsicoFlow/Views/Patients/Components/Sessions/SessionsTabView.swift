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
    
    let onAddFixed: () -> Void
    let onAddAvulsa: () -> Void
    
    var body: some View {
        VStack(spacing: 32) {
            
            // MARK: - Sessões Recorrentes
            VStack(alignment: .leading, spacing: 16) {
                HStack {
                    Text("Sessões Recorrentes")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.secondary)
                        .textCase(.uppercase)
                    
                    Spacer()
                    
                    Button(action: onAddFixed) {
                        Image(systemName: "plus")
                            .font(.system(size: 15, weight: .bold))
                            .foregroundColor(.teal)
                            .frame(width: 32, height: 32)
                            .background(.white)
                            .clipShape(Circle())
                    }
                }
                .padding(.horizontal, 20)
                
                if sessoesFixas.isEmpty {
                    VStack(spacing: 12) {
                        Image(systemName: "arrow.triangle.2.circlepath")
                            .font(.system(size: 32))
                            .foregroundColor(.gray.opacity(0.5))
                        
                        Text("Nenhuma sessão fixa configurada.")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 32)
                    .background(Color(.systemGray6))
                    .padding(.horizontal, 20)
                    .transition(.opacity.combined(with: .scale(scale: 0.95)))
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
            .animation(.spring(response: 0.4, dampingFraction: 0.8), value: sessoesFixas.count)
            
            // MARK: - Sessões Avulsas e Adiadas
            VStack(alignment: .leading, spacing: 16) {
                HStack {
                    Text("Sessões Avulsas e Adiadas")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.secondary)
                        .textCase(.uppercase)
                    
                    Spacer()
                    
                    Button(action: onAddAvulsa) {
                        Image(systemName: "plus")
                            .font(.system(size: 15, weight: .bold))
                            .foregroundColor(.teal)
                            .frame(width: 32, height: 32)
                            .background(.white)
                            .clipShape(Circle())
                    }
                }
                .padding(.horizontal, 20)
                
                if sessoesAvulsas.isEmpty {
                    VStack(spacing: 12) {
                        Image(systemName: "calendar.badge.clock")
                            .font(.system(size: 32))
                            .foregroundColor(.gray.opacity(0.5))
                        
                        Text("Nenhuma sessão avulsa programada para o futuro.")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 16)
                            .transition(.opacity.combined(with: .scale(scale: 0.95)))
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 32)
                    .background(Color(.systemGray6))
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
            .animation(.spring(response: 0.4, dampingFraction: 0.8), value: sessoesAvulsas.count)
        }
        .padding(.vertical, 16)
    }
}

