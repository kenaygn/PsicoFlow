//
//  PasswordToggleField.swift
//  PsicoFlow
//
//  Created by Kenay on 08/06/26.
//

import SwiftUI

struct PasswordToggleField: View {
    
    var title: String
    @Binding var text: String
    var contentType: UITextContentType
    
    @State private var isRevealed: Bool = false
    
    var body: some View {
        HStack {
            if isRevealed {
                TextField(title, text: $text)
                    .autocorrectionDisabled(true)
                    .textInputAutocapitalization(.never)
                    .textContentType(contentType)
            } else {
                SecureField(title, text: $text)
                    .autocorrectionDisabled(true)
                    .textInputAutocapitalization(.never)
                    .textContentType(contentType)
            }
            
            Button(action: {
                isRevealed.toggle()
            }) {
                Image(systemName: isRevealed ? "eye.slash.fill" : "eye.fill")
                    .foregroundColor(.teal)
            }
            .buttonStyle(PlainButtonStyle())
        }
    }
}
