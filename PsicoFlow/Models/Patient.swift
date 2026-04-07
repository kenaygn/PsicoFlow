//
//  Patient.swift
//  PsicoApp
//
//  Created by Kenay on 31/03/26.
//

import Foundation

enum PatientStatus: String, Codable, CaseIterable {
    case ativo = "Ativo"
    case inativo = "Inativo"
}

struct Patient: Identifiable, Codable {
    var id: String
    var psicologoID: String
    
    var nome: String
    var email: String
    var telefone: String
    var contatoEmergencia: String?
    var observacoes: String?
    
    var status: PatientStatus
    var valor: Double
    
    var criadoEm: Date
    
    // Propriedade para facilitar a UI
    var iniciais: String {
        nome.components(separatedBy: " ").prefix(2).compactMap { $0.first }.map { String($0) }.joined().uppercased()
    }
}
