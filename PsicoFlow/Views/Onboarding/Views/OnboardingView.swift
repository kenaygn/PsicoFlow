//
//  OnboardingView.swift
//  PsicoFlow
//
//  Created by Kenay on 09/06/26.
//

import SwiftUI

// MARK: - Modelo de Dados Atualizado
struct OnboardingFullScreenCard: Identifiable {
    let id = UUID()
    let tag: String
    let titulo: String
    let textoInicio: String
    let destaque: String
    let textoFim: String
    let iconeFundo: String
    let gradiente: [Color]
    // Dados para o Card de Vidro Central
    let infoTag: String
    let infoIcone: String
    let infoDescricao: String
}

struct OnboardingView: View {
    @Binding var viuOnboarding: Bool
    @State private var paginaAtual = 0
    
    // Dados configurados conforme o seu novo design
    private let paginas: [OnboardingFullScreenCard] = [
        OnboardingFullScreenCard(
            tag: "BEM-VINDO AO PSYES",
            titulo: "Mais tempo\npara cuidar",
            textoInicio: "Tiramos a carga burocrática dos seus ombros. ",
            destaque: "Foque no que importa:",
            textoFim: " o bem-estar dos seus pacientes.",
            iconeFundo: "brain.head.profile",
            gradiente: [
                Color(red: 0, green: 0.76, blue: 0.76),
                Color(red: 0, green: 0.63, blue: 0.62)
            ],
            infoTag: "SIGILO ABSOLUTO",
            infoIcone: "lock.shield.fill",
            infoDescricao: "Seus dados e evoluções clínicas são protegidos com criptografia de ponta a ponta"
        ),
        OnboardingFullScreenCard(
            tag: "AGENDA",
            titulo: "Controle seu\nhorário",
            textoInicio: "Organize suas sessões fixas e avulsas. ",
            destaque: "Evite conflitos:",
            textoFim: " tenha uma visão clara do seu dia.",
            iconeFundo: "calendar",
            gradiente: [Color(red: 30/255, green: 41/255, blue: 59/255), Color(red: 15/255, green: 23/255, blue: 42/255)],
            infoTag: "INTELIGÊNCIA",
            infoIcone: "sparkles",
            infoDescricao: "O aplicativo identifica e mostra claramente o dia e os horários sempre que houver qualquer conflito de agendamento."
        ),
        OnboardingFullScreenCard(
            tag: "FINANCEIRO",
            titulo: "Gestão de\nrecebíveis",
            textoInicio: "Monitore pagamentos e pendências. ",
            destaque: "Sem planilhas:",
            textoFim: " tudo automatizado para sua economia.",
            iconeFundo: "dollarsign.circle",
            gradiente: [Color(red: 251/255, green: 191/255, blue: 36/255), Color(red: 249/255, green: 115/255, blue: 22/255)],
            infoTag: "PRATICIDADE",
            infoIcone: "creditcard.fill",
            infoDescricao: "Monitore o status dos pagamentos mensais e controle pacotes de sessões de forma simples."
        )
    ]
    
    var body: some View {
        TabView(selection: $paginaAtual) {
            ForEach(0..<paginas.count, id: \.self) { index in
                FullScreenCardView(card: paginas[index])
                    .tag(index)
            }
        }
        .tabViewStyle(PageTabViewStyle(indexDisplayMode: .always))
        .ignoresSafeArea()
        .overlay(alignment: .bottom) {
            // Botão de Próximo exatamente como na imagem
            Button(action: {
                if paginaAtual < paginas.count - 1 {
                    withAnimation { paginaAtual += 1 }
                } else {
                    withAnimation { viuOnboarding = true }
                }
            }) {
                Text(paginaAtual == paginas.count - 1 ? "Começar" : "Próximo")
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(paginas[paginaAtual].gradiente[0]) // Usa a cor do tema no texto
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 20)
                    .background(Color.white)
                    .clipShape(Capsule())
            }
            .padding(.horizontal, 30)
            .padding(.bottom, 60)
        }
    }
}


#Preview {
    OnboardingView(viuOnboarding: .constant(false))
}
