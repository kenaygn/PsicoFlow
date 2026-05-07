//
//  PatientCardView.swift
//  PsicoApp
//
//  Created by Kenay on 04/04/26.
//

import SwiftUI

/// Componente visual que representa um paciente na listagem principal.
///
/// - Note: O card já inclui o `PlainButtonStyle()` para garantir que, ao ser
///         envolvido por um `NavigationLink` ou `Button` na View pai,
///         os textos e ícones não herdem o "tint color" azul padrão do iOS.
struct PatientCardView: View {
    
    let paciente: Patient
    
    var body: some View {
        HStack(spacing: 16) {
            
            // MARK: - Avatar e Status
            ZStack(alignment: .bottomTrailing) {
                Text(paciente.iniciais)
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(.primary)
                    .frame(width: 56, height: 56)
                    .background(Color(.systemGray6))
                    .clipShape(Circle())
                
                Circle()
                    .fill(paciente.status == .ativo ? Color.teal : Color(UIColor.lightGray))
                    .frame(width: 16, height: 16)
                    .overlay(Circle().stroke(Color.white, lineWidth: 2))
            }
            
            // MARK: - Informações
            VStack(alignment: .leading, spacing: 4) {
                Text(paciente.nome)
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundColor(.primary)
                    .tracking(-0.3)
                
                Text(paciente.telefone)
                    .font(.system(size: 13))
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(Color(.systemGray4))
        }
        .padding(16)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
        .shadow(color: Color.black.opacity(0.03), radius: 5, x: 0, y: 2)
        .overlay(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .stroke(Color.gray.opacity(0.1), lineWidth: 1)
        )
        .buttonStyle(PlainButtonStyle())
    }
}
