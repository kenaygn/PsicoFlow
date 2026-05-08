//
//  MainTabView.swift
//  PsicoApp
//
//  Created by Kenay on 04/04/26.
//

import SwiftUI

struct MainTabView: View {
    @State private var abaSelecionada = 0
    
    //EnviromentObjetc do login para dar acesso a todas as views a quem ta logado.
    
    var body: some View {
        TabView(selection: $abaSelecionada) {
            
            // 1. ABA: INÍCIO
            HomeView()
                .tabItem {
                    Image(systemName: "house.fill")
                    Text("Início")
                }
                .tag(0)
            
            // 2. ABA: AGENDA
            AgendaView()
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
            
            // 4. ABA: FINANÇAS
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
        .tint(.teal)
    }
}

#Preview {
    MainTabView()
}
