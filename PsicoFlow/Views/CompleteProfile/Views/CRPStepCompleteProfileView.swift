//
//  CRPStepCompleteProfileView.swift
//  PsicoFlow
//
//  Created by Kenay on 15/07/26.
//

import SwiftUI

struct CRPStepCompleteProfileView: View {
    @ObservedObject var vm: CompleteProfileViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            Text("Qual é o seu CRP?")
                .font(.title2).bold()
                .padding(.horizontal, 24)
                .padding(.bottom, -16)
            Text("Isso ajuda a manter seus documentos e prontuários organizados e dentro da validade ética.")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .padding(.horizontal, 24)
            
            UnderlinedTextField(placeholder: "Ex: 00/00000", text: $vm.crp, keyboardType: .numbersAndPunctuation)
            
            Spacer()
            PrimaryButton(texto: "Continuar", habilitado: !vm.crp.trimmingCharacters(in: .whitespaces).isEmpty) {
                
                hideKeyboard()
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                    withAnimation {
                        vm.avancarPasso()
                    }
                }
            }
        }
        .padding(.top, 20)
    }
}
