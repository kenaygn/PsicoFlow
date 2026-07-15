//
//  CompleteProfileView.swift
//  PsicoFlow
//
//  Created by Kenay on 15/07/26.
//

import SwiftUI

struct CompleteProfileView: View {
    @StateObject private var vm = CompleteProfileViewModel()
    
    var body: some View {
        VStack(spacing: 0) {

            if vm.passoAtual != .sucesso {
                ProgressView(
                    value: Double(vm.passoAtual.rawValue),
                    total: Double(PassoCadastro.allCases.count - 2)
                )
                .progressViewStyle(.linear)
                .tint(.teal)
                .padding(.horizontal, 24)
                .padding(.top, 20)
                .padding(.bottom, 30)
                .animation(.easeInOut, value: vm.passoAtual)
            }
            
            TabView(selection: $vm.passoAtual) {
                IntroStepCompleteProfileView(vm: vm).tag(PassoCadastro.introducao)
                NameStepCompleteProfileView(vm: vm).tag(PassoCadastro.nome)
                CRPStepCompleteProfileView(vm: vm).tag(PassoCadastro.crp)
                ScheduleStepCompleteProfileView(vm: vm).tag(PassoCadastro.horarios)
                SuccessStepCompleteProfileView().tag(PassoCadastro.sucesso)
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .animation(.easeInOut, value: vm.passoAtual)
        }
    }
}

#Preview {
    CompleteProfileView()
}
