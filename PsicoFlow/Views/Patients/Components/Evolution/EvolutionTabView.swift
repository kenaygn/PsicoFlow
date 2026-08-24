//
//  EvolutionTabView.swift
//  PsicoFlow
//
//  Created by Kenay on 04/04/26.
//

import SwiftUI

struct EvolutionTabView: View {
        
    var evolucoes: [Evolution]
    var adicionarEvolucao: ((String) -> Void)
    var atualizarEvolucao: ((Evolution) -> Void)
    var deletarEvolucao: ((String) -> Void)
    
    @State private var isShowingForm = false
    @State private var textoFormulario = ""
    @State private var evolucaoEmEdicao: Evolution? = nil
    
    @State private var mostrarAlertaExclusao = false
    @State private var evolucaoParaExcluir: Evolution? = nil
    
    var body: some View {
        VStack(spacing: 16) {
            
            HStack {
                Text("Anotações")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.primary)
                Spacer()
            }
            .padding(.bottom, 4)
            
            if isShowingForm {
                VStack(spacing: 16) {
                    TextEditor(text: $textoFormulario)
                        .frame(minHeight: 120)
                        .padding(12)
                        .background(Color(.systemGray6))
                        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                        .overlay(
                            RoundedRectangle(cornerRadius: 16, style: .continuous)
                                .stroke(Color.teal.opacity(0.3), lineWidth: 1)
                        )
                    
                    HStack(spacing: 12) {
                        Button( action:{
                            fecharFormulario()
                        }){
                            Text("Cancelar")
                                .font(.system(size: 15, weight: .semibold))
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 14)
                                .background(Color(.systemGray5))
                                .foregroundColor(.gray)
                                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                        }
                        
                        Button( action: {
                            if var evoParaAtualizar = evolucaoEmEdicao {
                                // MODO EDIÇÃO
                                evoParaAtualizar.conteudo = textoFormulario
                                atualizarEvolucao(evoParaAtualizar)
                            } else {
                                // MODO CRIAÇÃO
                                adicionarEvolucao(textoFormulario)
                            }
                            fecharFormulario()
                        }){
                            Text("Guardar")
                                .font(.system(size: 15, weight: .semibold))
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 14)
                                .background(Color.teal)
                                .foregroundColor(.white)
                                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                        }

                    }
                }
                .padding(20)
                .background(Color.white)
                .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
                .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 4)
                .transition(.opacity.combined(with: .scale(scale: 0.95)))
            }
            
            if !isShowingForm {
                Button(action: {
                    withAnimation(.spring()) {
                        evolucaoEmEdicao = nil
                        textoFormulario = ""
                        isShowingForm = true
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
            
            if evolucoes.isEmpty && !isShowingForm {
                VStack(spacing: 12) {
                    Image(systemName: "doc.text.magnifyingglass")
                        .font(.system(size: 40))
                        .foregroundColor(Color(.systemGray4))
                        .padding(.top, 40)
                    Text("Nenhuma anotação registrada.")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundColor(Color(.darkGray))
                    Text("Clique em 'Novo Registro' para iniciar uma anotação deste paciente.")
                        .font(.system(size: 13))
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 20)
                }
                .padding(.bottom, 60)
            } else {
                ForEach(evolucoes.sorted(by: { $0.data > $1.data })) { evolucao in
                    EvolutionCardView(
                        evolucao: evolucao,
                        onEdit: {
                            withAnimation(.spring()) {
                                evolucaoEmEdicao = evolucao
                                textoFormulario = evolucao.conteudo
                                isShowingForm = true
                            }
                        },
                        onDelete: {
                            evolucaoParaExcluir = evolucao
                            mostrarAlertaExclusao = true
                        }
                    )
                }
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 16)
        
        .alert("Excluir Anotação", isPresented: $mostrarAlertaExclusao) {
            Button("Cancelar", role: .cancel) { }
            Button("Excluir", role: .destructive) {
                if let evo = evolucaoParaExcluir {
                    deletarEvolucao(evo.id)
                }
            }
        } message: {
            Text("Tem certeza que deseja excluir esta anotação? Esta ação não pode ser desfeita.")
        }
    }
    
    private func fecharFormulario() {
        withAnimation(.spring()) {
            isShowingForm = false
            textoFormulario = ""
            evolucaoEmEdicao = nil
        }
    }
}
