//
//  PrivacySection.swift
//  PsicoFlow
//
//  Created by Kenay on 04/06/26.
//

import SwiftUI

struct PrivacySection: View {
    let title: String
    let content: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.headline)
                .foregroundColor(.cyan)
            
            Text(content)
                .font(.body)
                .foregroundColor(.primary)
                .lineSpacing(4)
        }
    }
}
