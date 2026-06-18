//
//  GlassCardView.swift
//  PsicoFlow
//
//  Created by Kenay on 09/06/26.
//

import SwiftUI

struct GlassCardView: View {
    
    var infoIcone: String
    var infoTag: String
    var infoDescricao: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 6) {
                Image(systemName: infoIcone)
                    .font(.system(size: 10))
                    .foregroundStyle(.white)
                Text(infoTag)
                    .font(.system(size: 10, weight: .bold))
                    .foregroundStyle(.white)
                    .tracking(0.5)
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 4)
            .background(.white.opacity(0.2))
            .clipShape(Capsule())
            
            Text(infoDescricao)
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(.white)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.white.opacity(0.15))
        .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .stroke(.white.opacity(0.2), lineWidth: 1)
        )
    }
}

#Preview {
    VStack{
        GlassCardView(infoIcone: "teste", infoTag: "ouuu", infoDescricao: "Abra cadabra")
    }
    .frame(maxHeight: .infinity)
    .background(Color.black)
    

}
