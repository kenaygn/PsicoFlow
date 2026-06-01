//
//  MainTabView.swift
//  PsicoApp
//
//  Created by Kenay on 04/04/26.
//

import SwiftUI

struct MainTabView: View {
    
    @StateObject private var router = AppRouter()
    
    //EnviromentObjetc do login para dar acesso a todas as views a quem ta logado.
    
    var body: some View {
        TabView(selection: $router.selectedTab) {
            
            // 1. ABA: INÍCIO
            HomeView()
                .tabItem {
                    Image(systemName: "house.fill")
                    Text("Início")
                }
                .tag(AppRouter.Tab.home)
            
            // 2. ABA: AGENDA
            AgendaView()
                .tabItem {
                    Image(systemName: "calendar")
                    Text("Agenda")
                }
                .tag(AppRouter.Tab.agenda)
            
            // 3. ABA: PACIENTES
            PatientsView()
                .tabItem {
                    Image(systemName: "person.2")
                    Text("Pacientes")
                }
                .tag(AppRouter.Tab.patients)
            
            // 4. ABA: FINANÇAS
            FinancesView()
                .tabItem {
                    Image(systemName: "dollarsign.circle")
                    Text("Finanças")
                }
                .tag(AppRouter.Tab.finances)
            
            // 5. ABA: AJUSTES (Placeholder)
            SettingsView()
                .tabItem {
                    Image(systemName: "gearshape")
                    Text("Ajustes")
                }
                .tag(AppRouter.Tab.settings)
        }
        .tint(.teal)
        .environmentObject(router)
    }
}

#Preview {
    MainTabView()
}
