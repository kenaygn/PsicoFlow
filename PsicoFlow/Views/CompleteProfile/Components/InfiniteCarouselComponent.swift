//
//  InfiniteCarouselComponent.swift
//  PsicoFlow
//
//  Created by Kenay on 15/07/26.
//

import SwiftUI

struct InfiniteCarousel: View {
    let items: [FakePaciente]
    let rolarParaEsquerda: Bool
    
    @State private var isAnimating = false
    
    let larguraDoCard: CGFloat = 268
    let espacamento: CGFloat = 16
    
    var larguraTotal: CGFloat {
        (larguraDoCard + espacamento) * CGFloat(items.count)
    }
    
    var duracao: Double {
        Double(items.count) * 6.0
    }
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: espacamento) {
                ForEach(0..<3, id: \.self) { _ in
                    ForEach(items) { paciente in
                        FakeSessionCard(paciente: paciente)
                            .frame(width: larguraDoCard)
                    }
                }
            }
            .offset(x: rolarParaEsquerda
                    ? (isAnimating ? -larguraTotal : 0)
                    : (isAnimating ? 0 : -larguraTotal))
            
            .animation(
                isAnimating ? .linear(duration: duracao).repeatForever(autoreverses: false) : .default,
                value: isAnimating
            )
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    isAnimating = true
                }
            }
            .onDisappear {
                isAnimating = false
            }
        }
        .disabled(true)
    }
}
