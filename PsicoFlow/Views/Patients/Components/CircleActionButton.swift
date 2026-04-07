//
//  CircleActionButton.swift
//  PsicoFlow
//
//  Created by Kenay on 04/04/26.
//

import SwiftUI

// Sub-componente para os botões redondos de ação
struct CircleActionButton: View {
    let icon: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundColor(color)
                .frame(width: 50, height: 50)
                .background(Color.white)
                .clipShape(Circle())
                .shadow(color: .black.opacity(0.05), radius: 5, y: 2)
                .overlay(Circle().stroke(Color.gray.opacity(0.1), lineWidth: 1))
        }
        
    }
}
