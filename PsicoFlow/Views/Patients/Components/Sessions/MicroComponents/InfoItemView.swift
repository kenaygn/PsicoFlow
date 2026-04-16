//
//  InfoItemView.swift
//  PsicoFlow
//
//  Created by Kenay on 16/04/26.
//

import SwiftUI

struct InfoItemView: View {
    let icon: String
    let title: String
    let value: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack(spacing: 4) {
                Image(systemName: icon).foregroundColor(.secondary)
                Text(title).foregroundColor(.secondary)
            }
            .font(.system(size: 12, weight: .medium))
            
            Text(value)
                .font(.system(size: 12, weight: .bold))
                .foregroundColor(Color(.darkText))
        }
    }
}

