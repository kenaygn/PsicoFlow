//
//  User.swift
//  PsicoApp
//
//  Created by Kenay on 31/03/26.
//

import Foundation

struct User: Identifiable, Codable {
    var id: String           // UID do Firebase Auth
    var name: String
    var crp: String
    var premium: Bool
    var createdAt: Date
    
    var workdayStart: String
    var workdayEnd: String
    
    // Propriedade Computada para a UI (Avatar)
    var initials: String {
        let componentes = name.components(separatedBy: " ")
        let primeiro = componentes.first?.first ?? "?"
        let ultimo = componentes.count > 1 ? componentes.last?.first ?? " " : " "
        return "\(primeiro)\(ultimo)".uppercased().trimmingCharacters(in: .whitespaces)
    }
    
    // Lógica de negócio baseada em dados
    var subscriptionStatus: String {
        premium ? "Premium" : "Gratuito"
    }
}
