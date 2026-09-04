//
//  UnderlinedTextFieldComponent.swift
//  PsicoFlow
//
//  Created by Kenay on 15/07/26.
//

import SwiftUI

struct UnderlinedTextField: View {
    let placeholder: String
    @Binding var text: String
    var keyboardType: UIKeyboardType = .default
    
    var body: some View {
        VStack(spacing: 8) {
            TextField(placeholder, text: $text)
                .keyboardType(keyboardType)
                .font(.title3)
            
            Rectangle()
                .frame(height: 1)
                .foregroundColor(Color(.systemGray3))
        }
        .padding(.horizontal, 24)
    }
}
