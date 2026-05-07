//
//  EvolutionTabView.swift
//  PsicoFlow
//
//  Created by Kenay on 04/04/26.
//

import SwiftUI

/// Aba responsável pela exibição do histórico clínico do paciente
/// e pela inserção rápida de novas evoluções através de um formulário inline.
struct EvolutionTabView: View {
        
    var evolucoes: [Evolution]
    var adicionarEvolucao: ((String) -> Void)
    
    @State private var isAddingNova = false
    @State private var novaEvolucaoTexto = ""
    
    var body: some View {
        VStack(spacing: 16) {
            
            // MARK: - Cabeçalho
            HStack {
                Text("Histórico Clínico")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.primary)
                
                Spacer()
                
                // TODO: Implementar busca no histórico de evoluções
            }
            .padding(.bottom, 4)
            
            // MARK: - Formulário Inline
            if isAddingNova {
                VStack(spacing: 16) {
                    TextEditor(text: $novaEvolucaoTexto)
                        .frame(minHeight: 120)
                        .padding(12)
                        .background(Color(.systemGray6))
                        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                        .overlay(
                            RoundedRectangle(cornerRadius: 16, style: .continuous)
                                .stroke(Color.teal.opacity(0.3), lineWidth: 1)
                        )
                    
                    HStack(spacing: 12) {
                        Button("Cancelar") {
                            withAnimation(.spring()) {
                                isAddingNova = false
                                novaEvolucaoTexto = ""
                            }
                        }
                        .font(.system(size: 15, weight: .semibold))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(Color(.systemGray5))
                        .foregroundColor(.gray)
                        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                        
                        Button("Guardar") {
                            adicionarEvolucao(novaEvolucaoTexto)
                            withAnimation(.spring()) {
                                isAddingNova = false
                                novaEvolucaoTexto = ""
                            }
                        }
                        .font(.system(size: 15, weight: .semibold))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(Color.teal)
                        .foregroundColor(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                    }
                }
                .padding(20)
                .background(Color.white)
                .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
                .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 4)
                .transition(.opacity.combined(with: .scale(scale: 0.95)))
            }
            
            // MARK: - Ações
            if !isAddingNova {
                Button(action: {
                    withAnimation(.spring()) {
                        isAddingNova = true
                    }
                }) {
                    HStack {
                        Image(systemName: "plus.circle.fill")
                        Text("Novo Registro")
                    }
                    .font(.system(size: 15, weight: .bold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(Color.teal)
                    .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                    .shadow(color: Color.teal.opacity(0.3), radius: 8, x: 0, y: 4)
                }
            }
            
            // MARK: - Lista de Evoluções e Estado Vazio
            if evolucoes.isEmpty && !isAddingNova {
                VStack(spacing: 12) {
                    Image(systemName: "doc.text.magnifyingglass")
                        .font(.system(size: 40))
                        .foregroundColor(Color(.systemGray4))
                        .padding(.top, 40)
                    
                    Text("Nenhuma evolução registrada.")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundColor(Color(.darkGray))
                    
                    Text("Clique em 'Novo Registro' para iniciar o prontuário deste paciente.")
                        .font(.system(size: 13))
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 20)
                }
                .padding(.bottom, 60)
            } else {
                // Note: A ordenação ocorre a cada renderização da View.
                //       Considere ordenar o array `evolucoes` diretamente na ViewModel
                //       para melhorar a performance caso o histórico clínico seja muito longo.
                ForEach(evolucoes.sorted(by: { $0.data > $1.data })) { evolucao in
                    EvolutionCardView(evolucao: evolucao)
                }
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 16)
    }
}
