//
//  FaceIDBlockView.swift
//  PsicoFlow
//
//  Created by Kenay on 02/06/26.
//

import SwiftUI

/// Tela de segurança apresentada quando o usuário exige biometria para entrar no app.
struct FaceIDBlockView: View {
    
    // Recebe o controle da RootView para avisar quando o app pode ser destrancado
    @Binding var estaDesbloqueado: Bool
    
    @StateObject private var vm = FaceIDBlockViewModel()
    
    var body: some View {
        VStack(spacing: 24) {
            Image(systemName: "faceid")
                .font(.system(size: 70))
                .foregroundColor(.teal)
            
            Text("PsicoFlow Bloqueado")
                .font(.title2)
                .fontWeight(.bold)
            
            Text("Use o Face ID para acessar sua agenda e pacientes.")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
            
            Button(action: {
                iniciarAutenticacao()
            }) {
                Text("Desbloquear")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(width: 200)
                    .padding(.vertical, 14)
                    .background(Color.teal)
                    .clipShape(Capsule())
            }
            .padding(.top, 20)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemBackground))
        .onAppear {
            iniciarAutenticacao()
        }
    }
    
    /// Solicita ao ViewModel que realize a autenticação e atualiza o estado da tela
    private func iniciarAutenticacao() {
        vm.autenticarParaEntrar { sucesso in
            if sucesso {
                // Rosto reconhecido OU senha digitada corretamente, libera o app com animação
                withAnimation {
                    self.estaDesbloqueado = true
                }
            } else {
                // Usuário cancelou ou errou, mantém bloqueado
                self.estaDesbloqueado = false
            }
        }
    }
}
