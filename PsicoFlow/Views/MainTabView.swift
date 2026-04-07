//
//  MainTabView.swift
//  PsicoApp
//
//  Created by Kenay on 04/04/26.
//

import SwiftUI

struct MainTabView: View {
    // Controla qual aba está ativa no momento
    @State private var abaSelecionada = 0
    
    var body: some View {
        TabView(selection: $abaSelecionada) {
            
            // 1. ABA: INÍCIO
            HomeView()
                .tabItem {
                    // Truque HIG: Ícone muda de vazado para preenchido quando clicado
                    Image(systemName: "house.fill")
                    Text("Início")
                }
                .tag(0)
            
            // 2. ABA: AGENDA (Placeholder)
            Text("Tela de Agenda em construção 🗓️")
                .font(.title)
                .foregroundColor(.gray)
                .tabItem {
                    Image(systemName: "calendar")
                    Text("Agenda")
                }
                .tag(1)
            
            // 3. ABA: PACIENTES
            PatientsView()
                .tabItem {
                    Image(systemName: "person.2")
                    Text("Pacientes")
                }
                .tag(2)
            
            // 4. ABA: FINANÇAS (Placeholder)
            FinancesView()
                .tabItem {
                    Image(systemName: "dollarsign.circle")
                    Text("Finanças")
                }
                .tag(3)
            
            // 5. ABA: AJUSTES (Placeholder)
            Text("Tela de Ajustes em construção ⚙️")
                .font(.title)
                .foregroundColor(.gray)
                .tabItem {
                    Image(systemName: "gearshape")
                    Text("Ajustes")
                }
                .tag(4)
        }
        // Pinta o ícone ativo com a cor principal do seu app
        .tint(.teal)
    }
}

#Preview {
    MainTabView()
}
