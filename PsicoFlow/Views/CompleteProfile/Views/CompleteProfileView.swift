//
//  CompleteProfileView.swift
//  PsicoFlow
//
//  Created by Kenay on 15/07/26.
//

import SwiftUI

// TODO: tirar isso daqui
extension View {
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

struct CompleteProfileView: View {
    @StateObject private var vm = CompleteProfileViewModel()
    
    var body: some View {
        VStack(spacing: 0) {
            if vm.passoAtual != .sucesso {
                HStack(spacing: vm.passoAtual != .introducao ? 16 : 0) {
                    if vm.passoAtual != .introducao {
                        Button {
                            
                            hideKeyboard()
                            
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                                withAnimation {
                                    vm.voltarPasso()
                                }
                            }
                        } label: {
                            Image(systemName: "chevron.left")
                                .font(.title3.bold())
                                .foregroundColor(.primary)
                                .frame(width: 24, height: 24)
                        }
                        .transition(.opacity.combined(with: .scale))
                    }else{
                        Button { } label: {
                            Image(systemName: "chevron.left")
                                .font(.title3.bold())
                                .foregroundColor(.primary)
                                .frame(width: 0, height: 24)
                        }
                        .transition(.opacity.combined(with: .scale))
                        .disabled(true)
                        .opacity(0)
                    }
                    
                    // Barra de Progresso
                    ProgressView(
                        value: Double(vm.passoAtual.rawValue),
                        total: Double(PassoCadastro.allCases.count - 2)
                    )
                    .progressViewStyle(.linear)
                    .tint(.teal)
                    .animation(.easeInOut, value: vm.passoAtual)
                }
                .padding(.horizontal, 32)
                .padding(.top, 20)
                .padding(.bottom, 16)
                .animation(.easeInOut, value: vm.passoAtual)
            }
            
            // MARK: - Telas
            TabView(selection: $vm.passoAtual) {
                IntroStepCompleteProfileView(vm: vm).tag(PassoCadastro.introducao)
                NameStepCompleteProfileView(vm: vm).tag(PassoCadastro.nome)
                CRPStepCompleteProfileView(vm: vm).tag(PassoCadastro.crp)
                ScheduleStepCompleteProfileView(vm: vm).tag(PassoCadastro.horarios)
                SuccessStepCompleteProfileView(vm: vm).tag(PassoCadastro.sucesso)
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .highPriorityGesture(DragGesture())
            .animation(.easeInOut, value: vm.passoAtual)
        }
        .onTapGesture {
            hideKeyboard()
        }
        
        //        .onChange(of: vm.passoAtual) { _ in
        //            hideKeyboard()
        //        }
    }
}

#Preview {
    CompleteProfileView()
}
