//
//  UpgradePlanView.swift
//  PsicoFlow
//
//  Created by Kenay on 22/07/26.
//

import SwiftUI
import StoreKit

struct UpgradePlanView: View {
    @Environment(\.dismiss) var dismiss
    
    @EnvironmentObject var authManager: AuthManager
    @StateObject private var storeManager = StoreManager()
    
    @State private var isAnimating: Bool = false
    var limiteAtingido: Bool = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Fundo Animado
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color(red: 0.37, green: 0.22, blue: 0.90),
                        Color(red: 0.75, green: 0.35, blue: 0.95)
                    ]),
                    startPoint: isAnimating ? .topLeading : .bottomLeading,
                    endPoint: isAnimating ? .bottomTrailing : .topTrailing
                )
                .ignoresSafeArea()
                
                // Coroa flutuante
                GeometryReader { geometry in
                    Image(systemName: "crown.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(width: geometry.size.width * 1.2)
                        .foregroundColor(.white.opacity(0.05))
                        .rotationEffect(.degrees(-30))
                        .position(x: geometry.size.width * 0.8, y: geometry.size.height * 0.75)
                }
                .ignoresSafeArea()
                
                // Conteúdo Principal
                VStack(spacing: 0) {
                    
                    //                     1. Banner de Limite Atingido (Topo)
                    if limiteAtingido{
                        HStack(alignment: .top, spacing: 12) {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .foregroundColor(.yellow)
                                .font(.system(size: 20))
                            
                            Text("Você atingiu o limite de pacientes do plano Free do Psyes.")
                                .font(.subheadline)
                                .fontWeight(.medium)
                                .foregroundColor(.white)
                                .multilineTextAlignment(.leading)
                            
                            Spacer()
                        }
                        .padding()
                        .background(Color.black.opacity(0.25))
                        .cornerRadius(12)
                        .padding(.horizontal, 24)
                        .padding(.top, 16)
                        .padding(.bottom, -40)
                    }
                    Spacer()
                    
                    VStack{
                        // 2. Oferta Especial e Título
                        VStack(spacing: 16) {
                            //                        Text("OFERTA ESPECIAL")
                            //                            .font(.subheadline)
                            //                            .fontWeight(.bold)
                            //                            .padding(.horizontal, 16)
                            //                            .padding(.vertical, 8)
                            //                            .background(Color.white.opacity(0.25))
                            //                            .foregroundColor(.white)
                            //                            .clipShape(Capsule())
                            
                            Text("Psyes Pro")
                                .font(.system(size: 40, weight: .bold))
                                .foregroundColor(.white)
                        }
                        
                        // 3. Preço
                        VStack(spacing: -8) {
                            Text("de R$ 50,00")
                                .font(.title3)
                                .strikethrough()
                                .foregroundColor(.white.opacity(0.7))
                            
                            HStack(alignment: .firstTextBaseline, spacing: 6) {
                                Text("Por")
                                    .font(.title2)
                                    .foregroundColor(.white.opacity(0.9))
                                
                                Text("R$ 29,90")
                                    .font(.system(size: 50, weight: .black, design: .default))
                                    .foregroundColor(.white)
                                
                                Text("/mês")
                                    .font(.title3)
                                    .foregroundColor(.white.opacity(0.9))
                            }
                        }
                        .padding(.vertical, 24)
                        
                        // 4. Destaque: Pacientes Ilimitados
                        HStack(spacing: 8) {
                            Image(systemName: "infinity")
                                .font(.system(size: 32, weight: .bold))
                                .foregroundColor(.white)
                                .frame(width: 44, height: 44)
                                .padding(8)
                                .background(Color.white.opacity(0.2))
                                .clipShape(Circle())
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Pacientes Ilimitados")
                                    .font(.title3)
                                    .fontWeight(.bold)
                                    .foregroundColor(.white)
                                
                                Text("Liberdade total para crescer. Cadastre e gerencie sem restrições.")
                                    .font(.subheadline)
                                    .foregroundColor(.white.opacity(0.8))
                                    .fixedSize(horizontal: false, vertical: true)
                            }
                        }
                        .padding(.vertical, 16)
                        .padding(.horizontal, 4)
                        .frame(maxWidth: .infinity)
                        .background(Color.white.opacity(0.15))
                        .cornerRadius(16)
                        
                    }
                    .padding(.vertical,32)
                    .padding(.horizontal, 14)
                    .frame(maxWidth: .infinity)
                    .background(Color.white.opacity(0.15))
                    .cornerRadius(16)
                    .overlay(
                        Image("premium")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 180)
                            .offset(x: 5, y: -45),
                        alignment: .topTrailing
                    )
                    .padding(.horizontal, 16)
                    
                    
                    
                    Spacer()
                    
                    // 5. Teste Grátis e Botão
                    VStack(spacing: 16) {
                        
                        VStack(spacing: 4) {
                            HStack(spacing: 8) {
                                Image(systemName: "gift.fill")
                                    .foregroundColor(.yellow)
                                Text("1 Mês de Teste Grátis")
                                    .font(.headline)
                                    .foregroundColor(.white)
                            }
                            
                            Text("Cancele a qualquer momento antes da cobrança.")
                                .font(.footnote)
                                .foregroundColor(.white.opacity(0.7))
                        }
                        
                        Button(action: {
                            // Pegamos o produto que foi carregado da Apple
                            guard let produto = storeManager.produtosDisponiveis.first else { return }
                            
                            Task {
                                do {
                                    // Chama o Face ID / Pagamento
                                    if let transacao = try await storeManager.comprar(produto) {
                                        print("COMPRA REALIZADA COM SUCESSO! ID: \(transacao.id)")
                                        
                                        if var usuarioAtualizado = authManager.usuarioAtual {
                                            
                                            // Muda o status localmente
                                            usuarioAtualizado.premium = true
                                            
                                            // Chama o repositório para salvar no banco
                                            let userRepository = UserFirebaseRepository()
                                            try? await userRepository.updateUser(user: usuarioAtualizado)
                                            
                                            print("Usuário atualizado para Premium no Firebase!")
                                        }
                                        
                                        dismiss() // Fecha a tela de vendas
                                    }
                                } catch {
                                    print("Falha na compra: \(error)")
                                }
                            }
                        }) {
                            ZStack {
                                // Se estiver carregando, mostra o spinner
                                if storeManager.estaComprando {
                                    ProgressView()
                                        .tint(Color(red: 0.65, green: 0.30, blue: 0.92))
                                } else {
                                    Text("Iniciar Teste Grátis")
                                        .font(.title3)
                                        .fontWeight(.bold)
                                        .foregroundColor(Color(red: 0.65, green: 0.30, blue: 0.92))
                                }
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 18)
                            .background(Color.white)
                            .cornerRadius(16)
                            .shadow(color: .black.opacity(0.2), radius: 10, y: 5)
                        }
                        .disabled(storeManager.estaComprando || storeManager.produtosDisponiveis.isEmpty)
                        .opacity(storeManager.produtosDisponiveis.isEmpty ? 0.5 : 1)
                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom, 40)
                }
            }
            .toolbar {
                // Toolbar ajustada com um ícone mais visível
                ToolbarItem(placement: .topBarLeading) {
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark")
                    }
                }
            }
            .toolbarBackground(.hidden, for: .navigationBar)
            .tint(.purple)
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 3.0).repeatForever(autoreverses: true)) {
                isAnimating = true
            }
        }
    }
}

#Preview {
    UpgradePlanView()
}
