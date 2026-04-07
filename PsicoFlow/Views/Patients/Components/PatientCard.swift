//
//  PatientCard.swift
//  PsicoApp
//
//  Created by Kenay on 04/04/26.
//

import SwiftUI

struct PatientCardView: View {
    let paciente: Patient
    
    var body: some View {
        // Transformamos o card em um botão para ter o efeito de "clique" (active:scale-[0.98])
        HStack(spacing: 16) {
            
            // 1. Avatar com Indicador de Status
            ZStack(alignment: .bottomTrailing) {
                // Círculo com a Inicial
                Text(paciente.iniciais)
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(.primary)
                    .frame(width: 56, height: 56)
                    .background(Color(.systemGray6)) // slate-100
                    .clipShape(Circle())
                
                // Bolinha de Status (Verde para Ativo, Cinza para Inativo)
                Circle()
                // Adapte a verificação de status para bater com o seu modelo real
                    .fill(paciente.status == .ativo ? Color.teal : Color(UIColor.lightGray))
                    .frame(width: 16, height: 16)
                // Bordinha branca ao redor da bolinha para não colar no avatar
                    .overlay(Circle().stroke(Color.white, lineWidth: 2))
            }
            
            // 2. Informações do Paciente
            VStack(alignment: .leading, spacing: 4) {
                Text(paciente.nome)
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundColor(.primary)
                    .tracking(-0.3) // tracking-tight
                
                Text(paciente.telefone)
                    .font(.system(size: 13))
                    .foregroundColor(.secondary) // slate-500
            }
            
            Spacer()
            
            // 3. Ícone de Seta (Chevron)
            Image(systemName: "chevron.right")
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(Color(.systemGray4)) // slate-300
        }
        .padding(16)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
        .shadow(color: Color.black.opacity(0.03), radius: 5, x: 0, y: 2)
        // Bordinha super sutil (border-slate-100)
        .overlay(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .stroke(Color.gray.opacity(0.1), lineWidth: 1)
        )
        
        // Remove o estilo azul padrão do botão do iOS para respeitar nossas cores
        .buttonStyle(PlainButtonStyle())
    }
}
