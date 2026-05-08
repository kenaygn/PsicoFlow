//
//  ConflictAlertCard.swift
//  PsicoFlow
//
//  Created by Kenay.
//

import SwiftUI

/// Componente visual de alerta crítico utilizado para notificar o usuário
/// sobre sobreposições ou conflitos de horário na agenda, exigindo resolução.
struct ConflictAlertCard: View {
        
    var dataDoConflito: Date
    var action: () -> Void
    
    // Note: Para projetos focados em iOS 15+, considere substituir a alocação do DateFormatter
    // pela nova API declarativa nativa: dataDoConflito.formatted(.dateTime.day().month(.wide))
    private var dataFormatada: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "pt_BR")
        formatter.dateFormat = "dd 'de' MMMM"
        return formatter.string(from: dataDoConflito)
    }
        
    var body: some View {
        Button(action: action) {
            ZStack {
                
                // MARK: - Background Gradient
                LinearGradient(
                    colors: [
                        Color(red: 248/255, green: 113/255, blue: 113/255), // Red 400
                        Color(red: 220/255, green: 38/255, blue: 38/255)    // Red 600
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                
                // MARK: - Elementos Decorativos
                GeometryReader { geo in
                    Circle()
                        .fill(Color.white.opacity(0.15))
                        .frame(width: 120, height: 120)
                        .blur(radius: 20)
                        .position(x: geo.size.width + 10, y: -10)
                    
                    Image(systemName: "exclamationmark.triangle.fill")
                        .font(.system(size: 140))
                        .foregroundColor(Color.white.opacity(0.1))
                        .position(x: geo.size.width - 20, y: geo.size.height / 2 + 10)
                }
                .clipped()
                
                // MARK: - Conteúdo (Textos)
                VStack(alignment: .leading, spacing: 12) {
                    Text("AÇÃO NECESSÁRIA")
                        .font(.system(size: 10, weight: .bold))
                        .tracking(1)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 5)
                        .background(Color.white.opacity(0.25))
                        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Conflito de Horário")
                            .font(.title3)
                            .fontWeight(.bold)
                        
                        // Concatenação de Text() permite formatação mista com acessibilidade (VoiceOver) contínua
                        Text("Você possui sessões com o mesmo horário no dia ")
                            .font(.subheadline)
                            .foregroundColor(Color.white.opacity(0.9))
                        + Text("\(dataFormatada)")
                            .font(.subheadline)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                        + Text(". Toque para resolver.")
                            .font(.subheadline)
                            .foregroundColor(Color.white.opacity(0.9))
                    }
                }
                .padding(20)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
            .shadow(color: Color(red: 220/255, green: 38/255, blue: 38/255).opacity(0.3), radius: 10, x: 0, y: 5)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    ConflictAlertCard(dataDoConflito: Date(), action: {})
}
