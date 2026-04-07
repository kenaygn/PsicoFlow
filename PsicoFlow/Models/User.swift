//
//  User.swift
//  PsicoApp
//
//  Created by Kenay on 31/03/26.
//

import Foundation

struct User: Identifiable, Codable {
    var id: String           // UID do Firebase Auth
    var nome: String
    var email: String
    var crp: String
    var premium: Bool
    var criadoEm: Date
    
    // Propriedade Computada para a UI (Avatar)
    var iniciais: String {
        let componentes = nome.components(separatedBy: " ")
        let primeiro = componentes.first?.first ?? "?"
        let ultimo = componentes.count > 1 ? componentes.last?.first ?? " " : " "
        return "\(primeiro)\(ultimo)".uppercased().trimmingCharacters(in: .whitespaces)
    }
    
    // Lógica de negócio baseada em dados
    var statusAssinatura: String {
        premium ? "Premium" : "Gratuito"
    }
}
