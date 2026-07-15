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
        VStack(spacing: 24) {
            Spacer()
            Image(systemName: "sparkles")
                .font(.system(size: 60))
                .foregroundColor(.teal)
            Text("Bem-vindo ao Psyes!")
                .font(.title).bold()
            Text("Antes de começarmos a organizar sua rotina de atendimentos e deixar tudo em paz, precisamos te conhecer um pouco melhor.\n\nLeva menos de um minuto!")
                .font(.body)
                .multilineTextAlignment(.center)
                .foregroundColor(.secondary)
                .padding(.horizontal, 32)
            Spacer()
            PrimaryButton(texto: "Vamos lá", habilitado: true) {
                withAnimation { vm.avancarPasso() }
            }
        }
    }
}
