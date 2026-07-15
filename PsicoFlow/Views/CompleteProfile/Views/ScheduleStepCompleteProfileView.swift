//
//  ScheduleStepCompleteProfileView.swift
//  PsicoFlow
//
//  Created by Kenay on 15/07/26.
//

import SwiftUI

struct ScheduleStepCompleteProfileView: View {
    @ObservedObject var vm: CompleteProfileViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            Text("Qual o seu horário de expediente?")
                .font(.title2).bold()
                .padding(.horizontal, 24)
                .padding(.bottom, -16)
            Text("Isso vai configurar a sua agenda padrão. Não se preocupe, você poderá mudar isso depois.")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .padding(.horizontal, 24)
            
            HStack(spacing: 32) {
                UnderlinedTimePicker(titulo: "Início", selecao: $vm.horaInicio, opcoes: vm.opcoesHorarios)
                UnderlinedTimePicker(titulo: "Fim", selecao: $vm.horaFim, opcoes: vm.opcoesHorarios)
            }
            .padding(.horizontal, 24)
            
            Spacer()
            PrimaryButton(texto: "Finalizar", habilitado: vm.formularioValido) {
                hideKeyboard()
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                    withAnimation {
                        vm.avancarPasso()
                    }
                }
            }
        }
        .padding(.top, 20)
    }
}
