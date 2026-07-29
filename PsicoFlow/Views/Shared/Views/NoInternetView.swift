//
//  NoInternetView.swift
//  PsicoFlow
//
//  Created by Kenay on 28/07/26.
//

import SwiftUI

struct NoInternetView: View {
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "wifi.exclamationmark")
                .font(.system(size: 80))
                .foregroundColor(.red)
            
            Text("Sem Conexão")
                .font(.title)
                .fontWeight(.bold)
            
            Text("O Psyes precisa de internet para sincronizar seus dados com segurança. Verifique sua conexão e tente novamente.")
                .font(.body)
                .multilineTextAlignment(.center)
                .foregroundColor(.secondary)
                .padding(.horizontal, 32)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemBackground))
    }
}

#Preview {
    NoInternetView()
}
