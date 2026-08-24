//
//  FullScreenCardView.swift
//  PsicoFlow
//
//  Created by Kenay on 09/06/26.
//

import SwiftUI

struct FullScreenCardView: View {
    let card: OnboardingFullScreenCard
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            
//            HStack(spacing: 6) {
//                Circle().fill(.white).frame(width: 6, height: 6)
//                Text(card.tag)
//                    .font(.system(size: 11, weight: .bold))
//                    .foregroundStyle(Color.white)
//                    .tracking(1)
//            }
//            .padding(.horizontal, 12)
//            .padding(.vertical, 6)
//            .background(.white.opacity(0.2))
//            .clipShape(Capsule())
            
            Spacer()
            
            Text(card.titulo)
                .font(.system(size: 48, weight: .bold, design: .rounded))
                .foregroundColor(.white)
                .lineSpacing(-5)
            
            (Text(card.textoInicio)
                .foregroundColor(.white.opacity(0.9)) +
             Text(card.destaque)
                .fontWeight(.bold)
                .foregroundColor(.white) +
             Text(card.textoFim)
                .foregroundColor(.white.opacity(0.9)))
            .font(.title3)
            .lineSpacing(4)
            
            
            // MARK: - Card Central de Vidro (Glassmorphism)
            GlassCardView(infoIcone: card.infoIcone, infoTag: card.infoTag, infoDescricao: card.infoDescricao)
            .padding(.top, 30)
            .padding(.bottom, 120)
            
            Spacer()
        }
        .padding(30)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
        // Imagem de Fundo (Cérebro/Logo)
        .background(
            Image(systemName: card.iconeFundo)
                .font(.system(size: 400))
                .foregroundColor(.white.opacity(0.06))
                .rotationEffect(.degrees(-16))
                .offset(x: 120, y: 250)
            , alignment: .center
        )
        .background(
            LinearGradient(colors: card.gradiente, startPoint: .top, endPoint: .bottom)
        )
    }
}
