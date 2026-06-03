//
//  FaceIDBlockView.swift
//  PsicoFlow
//
//  Created by Kenay on 02/06/26.
//

import SwiftUI
import LocalAuthentication

/// Tela de segurança apresentada quando o usuário exige biometria para entrar no app.
struct FaceIDBlockView: View {
    
    // Recebe o controle da RootView para avisar quando o app pode ser destrancado
    @Binding var estaDesbloqueado: Bool
    
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
                autenticarParaEntrar()
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
            autenticarParaEntrar()
        }
    }
    
    // MARK: - Função de Autenticação Biométrica
    private func autenticarParaEntrar() {
            let context = LAContext()
            var error: NSError?
            
            if context.canEvaluatePolicy(.deviceOwnerAuthentication, error: &error) {
                let motivo = "Desbloqueie o aplicativo para continuar."
                
                context.evaluatePolicy(.deviceOwnerAuthentication, localizedReason: motivo) { sucesso, _ in
                    DispatchQueue.main.async {
                        if sucesso {
                            // Rosto reconhecido OU senha digitada corretamente!
                            withAnimation { self.estaDesbloqueado = true }
                        } else {
                            // Usuário cancelou ou errou a senha
                            self.estaDesbloqueado = false
                        }
                    }
                }
            } else {
                // Dispositivo sem senha e sem biometria: libera por padrão
                DispatchQueue.main.async {
                    self.estaDesbloqueado = true
                }
            }
        }
}
