//
//  EvolutionTabView.swift
//  PsicoFlow
//
//  Created by Kenay on 04/04/26.
//

import SwiftUI

// MARK: - 2. A Aba Completa (Lista + Formulário)
struct EvolutionTabView: View {
    // Aqui nós recebemos as evoluções filtradas daquele paciente
    var evolucoes: [Evolution]
    var adicionarEvolucao: ((String) -> Void)
    
    // Estados para o formulário de Nova Evolução
    @State private var isAddingNova = false
    @State private var novaEvolucaoTexto = ""
    
    var body: some View {
        VStack(spacing: 16) {
            
            // Cabeçalho da Seção
            HStack {
                Text("Histórico Clínico")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.primary)
                Spacer()
                //                Button("Buscar") {
                //                    print("Abrir barra de busca das evoluções")
                //                }
                //                .font(.system(size: 15, weight: .semibold))
                //                .foregroundColor(.teal)
            }
            .padding(.bottom, 4)
            
            // --- FORMULÁRIO INLINE DE NOVA EVOLUÇÃO ---
            if isAddingNova {
                VStack(spacing: 16) {
                    TextEditor(text: $novaEvolucaoTexto)
                        .frame(minHeight: 120)
                        .padding(12)
                    // Fundo cinza clarinho para destacar a área de digitação
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
                .transition(.opacity.combined(with: .scale(scale: 0.95))) // Animação de entrada
            }
            
            // --- BOTÃO ADICIONAR (Quando formulário está fechado) ---
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
            
            // --- LISTA DE CARDS ---
            // Ordenamos da data mais recente para a mais antiga
            // --- LISTA DE CARDS OU ESTADO VAZIO ---
            if evolucoes.isEmpty && !isAddingNova {
                // Empty State: O que aparece quando o paciente é novo
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
                // Lista normal renderizada
                ForEach(evolucoes.sorted(by: { $0.data > $1.data })) { evolucao in
                    EvolutionCardView(evolucao: evolucao)
                }
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 16)
    }
}
