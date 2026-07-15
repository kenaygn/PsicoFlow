//
//  SuccessStepCompleteProfileView.swift
//  PsicoFlow
//
//  Created by Kenay on 15/07/26.
//

import SwiftUI

struct SuccessStepCompleteProfileView: View {
    // Variáveis de estado para controlar a linha do tempo das animações
    @State private var icone = "circle"
    @State private var isPulsing = false
    @State private var mostrarConteudo = false
    
    var body: some View {
        VStack(spacing: 24) {
            Spacer()
            
            Image(systemName: icone)
                .font(.system(size: 80))
                .foregroundColor(.teal)
                .contentTransition(.symbolEffect(.replace))
                .scaleEffect(isPulsing ? 1.1 : 1.0)
                .animation(.bouncy(duration: 0.8).repeatForever(autoreverses: true), value: isPulsing)
            
            VStack(spacing: 24) {
                Text("Tudo Pronto!")
                    .font(.title).bold()
                
                Text("O seu consultório já está configurado. Vamos começar a organizar a sua rotina.")
                    .font(.body)
                    .multilineTextAlignment(.center)
                    .foregroundColor(.secondary)
                    .padding(.horizontal, 32)
            }
            // Animação de fade in e subida
            .opacity(mostrarConteudo ? 1 : 0)
            .offset(y: mostrarConteudo ? 0 : 20)
            
            Spacer()
            
            PrimaryButton(texto: "Entrar no App", habilitado: true) {
                print("Ir para a HomeView!")
            }
            .opacity(mostrarConteudo ? 1 : 0)
            .animation(.easeInOut(duration: 0.5).delay(0.2), value: mostrarConteudo)
        }
        .onAppear {
            iniciarAnimacoes()
        }
    }
    
    private func iniciarAnimacoes() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            icone = "checkmark.circle.fill"
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
            withAnimation(.easeOut(duration: 0.6)) {
                mostrarConteudo = true
            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
            isPulsing = true
        }
    }
}

#Preview {
    SuccessStepCompleteProfileView()
}
