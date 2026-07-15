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
                HStack(spacing: 16) {
//                    if vm.passoAtual != .introducao {
//                        Button {
//                            withAnimation {
//                                vm.voltarPasso()
//                            }
//                        } label: {
//                            Image(systemName: "chevron.left")
//                                .font(.title3.bold())
//                                .foregroundColor(.primary)
//                                .frame(width: 24, height: 24)
//                        }
//                        .transition(.opacity.combined(with: .scale))
//                    }

                    // Barra de Progresso
                    ProgressView(
                        value: Double(vm.passoAtual.rawValue),
                        total: Double(PassoCadastro.allCases.count - 2)
                    )
                    .progressViewStyle(.linear)
                    .tint(.teal)
                    .animation(.easeInOut, value: vm.passoAtual)
                }
                .padding(.horizontal, 24)
                .padding(.top, 20)
                .padding(.bottom, 30)
                .animation(.easeInOut, value: vm.passoAtual)
            }
            
            // MARK: - Telas
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
