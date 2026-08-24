//
//  PsyesLoadingView.swift
//  PsicoFlow
//
//  Created by Kenay on 18/08/26.
//

import SwiftUI

struct PsyesLoadingView: View {
    let letras = Array("Psyes")
    @State private var isAnimating = false
    
    var body: some View {
        ZStack {
            Color(.systemBackground)
                .ignoresSafeArea()
            
            HStack(spacing: 4) {
                ForEach(0..<letras.count, id: \.self) { index in
                    Text(String(letras[index]))
                        .font(.system(size: 42, weight: .bold, design: .rounded))
                        .foregroundColor(.teal)
                        .offset(y: isAnimating ? -15 : 0)
                        .animation(
                            Animation
                                .easeInOut(duration: 0.5)
                                .repeatForever(autoreverses: true)
                                .delay(Double(index) * 0.12),
                            value: isAnimating
                        )
                }
            }
        }
        .onAppear {
            isAnimating = true
        }
    }
}

#Preview {
    PsyesLoadingView()
}

