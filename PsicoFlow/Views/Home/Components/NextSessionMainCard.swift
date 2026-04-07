//
//  NextSessionPrincipalCard.swift
//  PsicoApp
//
//  Created by Kenay on 02/04/26.
//

import SwiftUI

struct NextSessionMainCard: View {
    // Propriedades recebidas da ViewModel
    var session: Session
    var nomeDaPaciente: String
    var onAbrirProntuario: () -> Void
    
    // Estado para controlar a animação do ponto pulsante
    @State private var isPulsing = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            
            // CABEÇALHO: Ponto pulsante, Título e Horário
            HStack {
                HStack(spacing: 8) {
                    // Ponto com animação de "Ping"
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
                        .tracking(0.5) // Leve espaçamento entre as letras
                }
                
                Spacer()
                
                // Pílula de Horário
                Text(session.horaInicio)
                    .font(.headline)
                    .fontWeight(.bold)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Color.white.opacity(0.15))
                    .foregroundColor(.white)
                    .clipShape(Capsule())
            }
            
            // CORPO: Nome do Paciente
            Text(nomeDaPaciente)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.white)
                .padding(.top, -16)
            
            
            // RODAPÉ: Botões de Ação
            HStack(spacing: 12) {
                // Botão Principal
                
                Button(action: onAbrirProntuario) {
                    Text("Abrir Prontuário")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(Color.white)
                        .foregroundColor(.black) // Cor do texto escura para contrastar
                        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                }
                
                // Botão Secundário (Ícone)
                Button(action: {
                    // Ação para ver detalhes do agendamento (opcional)
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
        // Usamos um cinza bem escuro para dar destaque, simulando o Slate-900
        .background(.backgroundDark)
        .overlay{
            Circle()
            .fill(Color.white.opacity(0.05))
            .frame(width: 140, height: 140)
            .offset(x: 140, y: -60)
        }
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
        .shadow(color: Color.black.opacity(0.15), radius: 15, x: 0, y: 8)

    }
}


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
