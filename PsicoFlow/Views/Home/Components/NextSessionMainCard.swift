//
//  NextSessionMainCard.swift
//  PsicoApp
//
//  Created by Kenay on 02/04/26.
//

import SwiftUI

/// Card de destaque principal (Hero) que exibe a sessão imediata do psicólogo.
/// Utiliza um indicador visual pulsante para chamar a atenção para o próximo atendimento.
struct NextSessionMainCard: View {
        
    var session: Session
    var nomeDaPaciente: String
    var onAbrirProntuario: () -> Void
    
    @State private var isPulsing = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            
            // MARK: - Cabeçalho e Indicador de Status
            HStack {
                HStack(spacing: 8) {
                    ZStack {
                        Circle()
                            .fill(Color.teal)
                            .frame(width: 10, height: 10)
                            .scaleEffect(isPulsing ? 1.8 : 1.0)
                            .opacity(isPulsing ? 0.0 : 0.8)
                            .animation(.easeInOut(duration: 1.5).repeatForever(autoreverses: false), value: isPulsing)
                        
                        Circle()
                            .fill(Color.teal)
                            .frame(width: 8, height: 8)
                    }
                    .onAppear {
                        isPulsing = true
                    }
                    
                    Text("PRÓXIMA SESSÃO")
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundColor(.teal)
                        .tracking(0.5)
                }
                
                Spacer()
                
                Text(session.horaInicio)
                    .font(.headline)
                    .fontWeight(.bold)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Color.white.opacity(0.15))
                    .foregroundColor(.white)
                    .clipShape(Capsule())
            }
            
            // MARK: - Informações do Paciente
            Text(nomeDaPaciente)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.white)
                .padding(.top, -16)
            
            // MARK: - Ações
            HStack(spacing: 12) {
                Button(action: onAbrirProntuario) {
                    Text("Abrir Prontuário")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(Color.white)
                        .foregroundColor(.black)
                        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                }
                
                // TODO: Definir ação ou navegação para a visualização de detalhes do agendamento
                Button(action: {
                    
                }) {
                    Image(systemName: "clock")
                        .font(.title3)
                        .fontWeight(.medium)
                        .frame(width: 48, height: 48)
                        .background(Color.white.opacity(0.15))
                        .foregroundColor(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                }
            }
        }
        .padding(20)
        .background(.backgroundDark)
        
        .overlay {
            Circle()
                .fill(Color.white.opacity(0.05))
                .frame(width: 140, height: 140)
                .offset(x: 140, y: -60)
        }
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
        .shadow(color: Color.black.opacity(0.15), radius: 15, x: 0, y: 8)
    }
}

// MARK: - Preview

#Preview {
    NextSessionMainCard(
        session: MockData.sessoesExemplo.first!,
        nomeDaPaciente: MockData.listaPacientes.first!.nome,
        onAbrirProntuario: {
            print("Navegar para o prontuário")
        }
    )
    .padding()
}
