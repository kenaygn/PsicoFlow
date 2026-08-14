//
//  PsyesWidgetLiveActivity.swift
//  PsyesWidget
//
//  Created by Kenay on 13/08/26.
//

import ActivityKit
import WidgetKit
import SwiftUI

// MARK: - CONFIGURAÇÃO PRINCIPAL
struct PsyesWidgetLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: SessionActivityAttributes.self) { context in
            // Delega a decisão de qual tela desenhar para o nosso roteador
            PsyesActivityContentView(context: context)
            
        } dynamicIsland: { context in
            let primeiroNome = context.attributes.nomePaciente.components(separatedBy: " ").first ?? context.attributes.nomePaciente
            
            // MARK: - DYNAMIC ISLAND
            return DynamicIsland {
                DynamicIslandExpandedRegion(.leading) {
                    HStack(spacing: 6) {
                        Circle().fill(Color.teal).frame(width: 6, height: 6)
                        Text("PRÓXIMA")
                            .font(.system(size: 10, weight: .bold))
                            .tracking(1)
                            .foregroundColor(.teal)
                    }
                    .padding(.horizontal, 10).padding(.vertical, 5)
                    .background(Color.teal.opacity(0.15))
                    .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                    .padding(.leading, 8)
                }
                
                DynamicIslandExpandedRegion(.trailing) {
                    Text(context.attributes.horaInicio)
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(.white)
                        .padding(.horizontal, 10).padding(.vertical, 5)
                        .background(Color.white.opacity(0.2))
                        .clipShape(Capsule())
                        .padding(.trailing, 8)
                }
                
                DynamicIslandExpandedRegion(.bottom) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text(context.attributes.nomePaciente)
                            .font(.title3).fontWeight(.bold).foregroundColor(.white)
                        
                        HStack(spacing: 12) {
                            if context.attributes.isFixa {
                                HStack(spacing: 4) { Image(systemName: "repeat"); Text("Fixa") }
                                .foregroundColor(Color(red: 0.89, green: 0.25, blue: 0.35))
                            } else {
                                HStack(spacing: 4) { Image(systemName: "1.circle"); Text("Avulsa") }
                                .foregroundColor(.orange)
                            }
                            
                            HStack(spacing: 4) {
                                Image(systemName: context.attributes.modalidade.lowercased() == "online" ? "video.fill" : "person.2.fill")
                                Text(context.attributes.modalidade.capitalized)
                            }
                            .foregroundColor(Color.white.opacity(0.7))
                            
                            HStack(spacing: 4) { Image(systemName: "clock"); Text("50 min") }
                            .foregroundColor(Color.white.opacity(0.7))
                        }
                        .font(.system(size: 13, weight: .medium))
                        
                        Text(context.state.statusMensagem)
                            .font(.subheadline).foregroundColor(Color.white.opacity(0.9)).padding(.top, 4)
                    }
                    .padding(.leading, -88).padding(.horizontal, 8).padding(.bottom, 8).padding(.top, 4)
                }
                
            } compactLeading: {
                Text(primeiroNome)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.teal)
                    .lineLimit(1)
                    .padding(.leading, 4)
                
            } compactTrailing: {
                Text(context.attributes.horaInicio)
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(.white)
                    .padding(.trailing, 4)
                
            } minimal: {
                Text(String(primeiroNome.prefix(1)))
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.teal)
            }
            .keylineTint(.teal)
        }
        //IOS 18 / WATCHOS 11
        // Isso avisa ao sistema que nós temos uma view sob medida para o Smart Stack
        .supplementalActivityFamilies([.small])
    }
}

// MARK: - ROTEADOR DE AMBIENTE
struct PsyesActivityContentView: View {
    @Environment(\.activityFamily) var activityFamily
    let context: ActivityViewContext<SessionActivityAttributes>

    var body: some View {
        switch activityFamily {
        case .small:
            // O Apple Watch vai cair obrigatoriamente aqui
            WatchSmartStackView(context: context)
        case .medium:
            // A Tela de Bloqueio do iPhone/iPad vai cair aqui
            LockScreenView(context: context)
        @unknown default:
            LockScreenView(context: context)
        }
    }
}

// MARK: - TELA DO IPHONE (LOCK SCREEN)
struct LockScreenView: View {
    let context: ActivityViewContext<SessionActivityAttributes>
    
    let darkSlateGradient = LinearGradient(
        colors: [Color(red: 30/255, green: 41/255, blue: 59/255), Color(red: 15/255, green: 23/255, blue: 42/255)],
        startPoint: .topLeading, endPoint: .bottomTrailing
    )
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                HStack(spacing: 6) {
                    Circle().fill(Color.white).frame(width: 6, height: 6)
                    Text("PRÓXIMA SESSÃO").font(.system(size: 10, weight: .bold)).tracking(1)
                }
                .padding(.horizontal, 10).padding(.vertical, 5)
                .background(Color.white.opacity(0.25))
                .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                
                Spacer()
                
                Text(context.attributes.horaInicio)
                    .font(.system(size: 12, weight: .bold))
                    .padding(.horizontal, 10).padding(.vertical, 5)
                    .background(Color.white.opacity(0.2))
                    .clipShape(Capsule())
            }
            
            VStack(alignment: .leading, spacing: 8) {
                Text(context.attributes.nomePaciente)
                    .font(.title3).fontWeight(.bold)
                
                HStack(spacing: 12) {
                    if context.attributes.isFixa {
                        HStack(spacing: 4) { Image(systemName: "repeat"); Text("Fixa") }
                        .foregroundColor(Color(red: 0.89, green: 0.25, blue: 0.35))
                    } else {
                        HStack(spacing: 4) { Image(systemName: "1.circle"); Text("Avulsa") }
                        .foregroundColor(.orange)
                    }
                    
                    HStack(spacing: 4) {
                        Image(systemName: context.attributes.modalidade.lowercased() == "online" ? "video.fill" : "person.2.fill")
                        Text(context.attributes.modalidade.capitalized)
                    }
                    .foregroundColor(Color.white.opacity(0.7))
                    
                    HStack(spacing: 4) { Image(systemName: "clock"); Text("50 min") }
                    .foregroundColor(Color.white.opacity(0.7))
                }
                .font(.system(size: 13, weight: .medium))
            }
        }
        .padding(20)
        .foregroundColor(.white)
        .background(darkSlateGradient)
        .activitySystemActionForegroundColor(Color.black)
    }
}

// MARK: - TELA DO APPLE WATCH (SMART STACK)
struct WatchSmartStackView: View {
    let context: ActivityViewContext<SessionActivityAttributes>
    
    // Cor de fundo sólida e premium para o Apple Watch
    let watchBackgroundColor = Color(red: 15/255, green: 23/255, blue: 42/255)
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Header e Nome mais compactos
            HStack {
                Text(context.attributes.nomePaciente)
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .lineLimit(1)
                
                Spacer()
                
                Text(context.attributes.horaInicio)
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.teal)
            }
            
            // Apenas tags essenciais
            HStack(spacing: 8) {
                HStack(spacing: 4) {
                    Image(systemName: context.attributes.isFixa ? "repeat" : "1.circle")
                    Text(context.attributes.isFixa ? "Fixa" : "Avulsa")
                }
                .font(.system(size: 12, weight: .bold))
                .foregroundColor(context.attributes.isFixa ? Color(red: 0.89, green: 0.25, blue: 0.35) : .orange)
                
                HStack(spacing: 4) {
                    Image(systemName: context.attributes.modalidade.lowercased() == "online" ? "video.fill" : "person.2.fill")
                    Text(context.attributes.modalidade.capitalized)
                }
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(.white.opacity(0.8))
            }
        }
        .padding(16) // Padding interno menor para otimizar espaço no relógio
        // Garante que o relógio aplique o fundo no container e ignore as cores neutras do sistema
        .containerBackground(for: .widget) {
            watchBackgroundColor
        }
    }
}

// MARK: - Previews (Mantidos para validação visual)
#Preview("Tela de Bloqueio - Fixa", as: .content, using: SessionActivityAttributes(
    nomePaciente: "Ana Carolina", modalidade: "Presencial", isFixa: true, horaInicio: "14:00"
)) {
    PsyesWidgetLiveActivity()
} contentStates: {
    SessionActivityAttributes.ContentState(statusMensagem: "Tudo pronto para o atendimento.")
}
