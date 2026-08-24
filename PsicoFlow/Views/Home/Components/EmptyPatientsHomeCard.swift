//
//  EmptyPatientsHomeCard.swift
//  PsicoFlow
//
//  Created by Kenay on 24/08/26.
//

import SwiftUI

struct EmptyPatientsHomeCard: View {
    
    var actionButton: () -> Void
    
    var body: some View {
        VStack(spacing: 12) {
            
            Image(systemName: "person.badge.plus")
                .font(.system(size: 40))
                .foregroundColor(.teal.opacity(0.8)) 
            
            Text("Primeiros passos")
                .font(.title3)
                .fontWeight(.bold)
                .foregroundColor(.teal)
            
            Text("O primeiro passo para organizar sua clínica é cadastrar um paciente. Vamos começar?")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 20)
            
            Button(action: {
                actionButton()
            }) {
                HStack(spacing: 8) {
                    Image(systemName: "plus")
                        .font(.system(size: 14, weight: .bold))
                    Text("Cadastrar Paciente")
                        .font(.headline)
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(Color.teal)
                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            }
            .padding(.horizontal, 20)
            .padding(.top, 12)
        }
        .padding(.vertical, 32)
        .frame(maxWidth: .infinity)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .stroke(Color.gray.opacity(0.1), lineWidth: 1)
        )
        .padding(.bottom, 24)
    }
}

#Preview {
    ZStack {
        Color(.systemGray6).ignoresSafeArea()
        EmptyPatientsHomeCard(actionButton: {})
            .padding()
    }
}
