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
    var isDark: Bool = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack(spacing: 4) {
                Image(systemName: icon)
                    .foregroundColor(isDark ? .white.opacity(0.8) : title == "Status" ? .orange : .secondary)
                Text(title)
                    .foregroundColor(isDark ? .white.opacity(0.8) : .secondary)
            }
            .font(.system(size: 12, weight: .medium))
            
            Text(value)
                .font(.system(size: 15, weight: .bold))
                .foregroundColor(isDark ? .white : Color(.darkText))
        }
    }
}
