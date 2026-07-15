//
//  SuccessStepCompleteProfileView.swift
//  PsicoFlow
//
//  Created by Kenay on 15/07/26.
//

import SwiftUI

struct SuccessStepCompleteProfileView: View {
    var body: some View {
        VStack(spacing: 24) {
            Spacer()
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 80))
                .foregroundColor(.teal)
            Text("Tudo Pronto!")
                .font(.title).bold()
            Text("O seu consultório já está configurado. Vamos começar a organizar a sua rotina.")
                .font(.body)
                .multilineTextAlignment(.center)
                .foregroundColor(.secondary)
                .padding(.horizontal, 32)
            Spacer()
            PrimaryButton(texto: "Entrar no App", habilitado: true) {
                print("Ir para a HomeView!")
            }
        }
    }
}
