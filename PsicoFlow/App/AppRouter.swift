//
//  AppRouter.swift
//  PsicoFlow
//
//  Created by Kenay on 08/05/26.
//

import SwiftUI
import Combine

class AppRouter: ObservableObject {
    
    enum Tab{
        case home
        case agenda
        case patients
        case finances
        case settings
    }
    
    @Published var selectedTab: Tab = .home
    
    @Published var conflictDay: Date?
    @Published var pendingMonth: Date?
    
    func goToAgendaConflict(day: Date){
        self.conflictDay = day
        self.selectedTab = .agenda
    }
    
    func goToFinancePendingMonth(month: Date){
        self.pendingMonth = month
        self.selectedTab = .finances
    }
    
    
}
