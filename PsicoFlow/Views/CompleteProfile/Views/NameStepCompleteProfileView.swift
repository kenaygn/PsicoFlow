//
//  NameStepCompleteProfileView.swift
//  PsicoFlow
//
//  Created by Kenay on 15/07/26.
//

import SwiftUI

struct NameStepCompleteProfileView: View {
    @ObservedObject var vm: CompleteProfileViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            Text("Como podemos te chamar?")
                .font(.title2).bold()
                .padding(.horizontal, 24)
                .padding(.bottom, -16)
            Text("Este será o nome que usaremos para personalizar o seu espaço de trabalho.")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .padding(.horizontal, 24)
            
            UnderlinedTextField(placeholder: "Ex: Dr. João Silva", text: $vm.nome)
            
            Spacer()
            PrimaryButton(texto: "Continuar", habilitado: !vm.nome.trimmingCharacters(in: .whitespaces).isEmpty) {
                withAnimation { vm.avancarPasso() }
            }
        }
        .padding(.top, 20)
    }
}
