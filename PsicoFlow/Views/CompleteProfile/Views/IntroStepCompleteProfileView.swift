//
//  IntroStepCompleteProfileView.swift
//  PsicoFlow
//
//  Created by Kenay on 15/07/26.
//

import SwiftUI

struct IntroStepCompleteProfileView: View {
    @ObservedObject var vm: CompleteProfileViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            
            VStack(alignment: .leading, spacing: 24) {
                Text("Bem-vindo ao Psyes!")
                    .font(.title).bold()
                    .padding(.bottom, -16)
                Text("Antes de começarmos a organizar sua rotina de atendimentos e deixar tudo em paz, precisamos te conhecer um pouco melhor.")
                    .font(.subheadline)
                    .foregroundColor(.secondary)    
            }
            .padding(.horizontal, 24)
            .padding(.top, 20)
            
            Spacer()
            
            // MARK: O Meio da Tela
            VStack(spacing: 16) {
                InfiniteCarousel(items: pacientesFila1, rolarParaEsquerda: true)
                
                InfiniteCarousel(items: pacientesFila2, rolarParaEsquerda: false)
                
            }
            .padding(.horizontal, -8)
            
            Spacer()
            
            VStack(spacing: 16) {
                Text("Leva menos de um minuto!")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                PrimaryButton(texto: "Vamos lá", habilitado: true) {
                    withAnimation { vm.avancarPasso() }
                }
            }
        }
    }
}
