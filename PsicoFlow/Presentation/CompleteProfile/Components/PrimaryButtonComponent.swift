//
//  PrimaryButtonComponent.swift
//  PsicoFlow
//
//  Created by Kenay on 15/07/26.
//

import SwiftUI

struct PrimaryButton: View {
    let texto: String
    let habilitado: Bool
    let acao: () -> Void
    
    var body: some View {
        Button(action: acao) {
            Text(texto)
                .font(.headline)
                .frame(maxWidth: .infinity)
                .padding()
                .background(habilitado ? Color.teal : Color.gray.opacity(0.3))
                .foregroundColor(.white)
                .cornerRadius(12)
        }
        .disabled(!habilitado)
        .padding(.horizontal, 24)
        .padding(.bottom, 32)
    }
}



