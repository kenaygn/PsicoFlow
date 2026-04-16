//
//  PatientDetailView.swift
//  PsicoFlow
//
//  Created by Kenay on 04/04/26.
//

import SwiftUI

struct PatientDetailView: View {
    // 1. Instanciamos a ViewModel correta para esta tela
    @StateObject private var viewModel: PatientDetailViewModel
    
    // Controles visuais (que são da View mesmo)
    @State private var abaSelecionada = 0
    @State private var mostrarModalEdicao = false
    
    
    // 2. O Init limpo: Recebe o paciente da lista e passa direto para a ViewModel
    init(paciente: Patient) {
        self._viewModel = StateObject(wrappedValue: PatientDetailViewModel(paciente: paciente))
    }
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 24) {
                
                // --- 1. CABEÇALHO DO PERFIL ---
                VStack(spacing: 12) {
                    Text(viewModel.paciente.iniciais)
                        .font(.system(size: 32, weight: .bold))
                        .foregroundColor(Color(.darkGray))
                        .frame(width: 88, height: 88)
                        .background(Color(.systemGray6))
                        .clipShape(Circle())
                        .overlay(Circle().stroke(Color.white, lineWidth: 4))
                        .shadow(color: .black.opacity(0.05), radius: 8, y: 4)
                    
                    VStack(spacing: 4) {
                        Text(viewModel.paciente.nome)
                            .font(.system(size: 24, weight: .bold))
                            .multilineTextAlignment(.center)
                        
                        Text(viewModel.paciente.status.rawValue.uppercased())
                            .font(.system(size: 11, weight: .bold))
                            .foregroundColor(viewModel.paciente.status == .ativo ? .green : .gray)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 4)
                            .background(viewModel.paciente.status == .ativo ? Color.green.opacity(0.1) : Color.gray.opacity(0.1))
                            .clipShape(Capsule())
                    }
                    
                    // Botões de Ação Rápida
                    HStack(spacing: 16) {
                        CircleActionButton(icon: "phone.fill", color: .teal) { print("Ligar") }
                        CircleActionButton(icon: "message.fill", color: .green) { print("WhatsApp") }
                        CircleActionButton(icon: "envelope.fill", color: .blue) { print("Email") }
                    }
                    .padding(.top, 8)
                }
                .padding(.top, 24)
                
                // --- 2. CONTROLE DE ABAS ---
                Picker("Abas", selection: $abaSelecionada) {
                    Text("Evolução").tag(0)
                    Text("Faturação").tag(1)
                    Text("Sessões").tag(2)
                }
                .pickerStyle(.segmented)
                .padding(.horizontal, 20)
                
                // --- 3. CONTEÚDO DAS ABAS ---
                VStack {
                    if abaSelecionada == 0 {
                        EvolutionTabView(
                            evolucoes: viewModel.evolucoes,
                            adicionarEvolucao: { textoDigitado in
                                viewModel.adicionarEvolucao(texto: textoDigitado)
                            }
                        )
                    } else if abaSelecionada == 1 {
                        BillingTabView(
                            pagamentos: viewModel.pagamentos,
                            onTogglePagamento: { idPagamento in
                                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                    viewModel.togglePagamento(pagamentoID: idPagamento)
                                }
                            }
                        )
                    } else if abaSelecionada == 2 {
                        SessionsTabView(
                            sessoesFixas: viewModel.sessoesFixas,
                            sessoesAvulsas: viewModel.sessoesAvulsasFuturas,
                            converterDia: { dia in viewModel.nomeDoDiaDaSemana(dia) },
                            onEditFixed: { fixa in
                                print("Abrir modal de edição com a regra fixa: \(fixa.horaInicio)")
                                // Aqui você vai disparar a variável @State para abrir sua NewSessionView em modo edição
                            },
                            onEditAvulsa: { avulsa in
                                print("Abrir modal de edição para sessão avulsa de \(avulsa.horaInicio)")
                                // Idem para sessão avulsa
                            }
                        )
                    }
                }
            }
            .padding(.bottom, 40)
        }
        .onAppear{
            viewModel.carregarDadosCompletos()
        }
        .onTapGesture {
            esconderTeclado()
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle("Perfil Clínico")
        .navigationBarTitleDisplayMode(.inline)
        
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Editar") {
                    mostrarModalEdicao = true
                }
                .fontWeight(.semibold)
                .foregroundColor(.teal)
            }
        }
        .sheet(isPresented: $mostrarModalEdicao) {
            // 4. Passamos a referência (Binding) do paciente que está na ViewModel
            EditPatientView(pacienteAtual: $viewModel.paciente)
                .onDisappear {
                    // Quando fechar, avisamos a tela de trás (a lista)
                    viewModel.salvarAlteracoesDoPaciente()                }
        }
    }
}

// Essa extensão permite usar o esconderTeclado() em qualquer lugar do app!
extension View {
    func esconderTeclado() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

#Preview {
    PatientDetailView(
        paciente: Patient(
            id: "p1",
            psicologoID: "user_dev_01",
            nome: "Ana Carolina Silva",
            email: "ana@email.com",
            telefone: "(11) 98765-4321",
            status: .ativo,
            valor: 150.0,
            criadoEm: Date()
        )
    )
}

