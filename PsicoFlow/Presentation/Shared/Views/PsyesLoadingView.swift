//
//  PsyesLoadingView.swift
//  PsicoFlow
//
//  Created by Kenay on 18/08/26.
//

import SwiftUI

struct PsyesLoadingView: View {
    let imagens = ["logo_p", "logo_s", "logo_y", "logo_e", "logo_s"]
    @State private var isAnimating = false
    
    var body: some View {
        ZStack {
            Color(.systemBackground)
                .ignoresSafeArea()
            
            HStack(spacing: 4) {
                ForEach(0..<imagens.count, id: \.self) { index in
                    Image(imagens[index])
                        .resizable()
                        .scaledToFit()
                        .frame(height: 72)
                        
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
