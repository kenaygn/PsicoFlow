//
//  Patient.swift
//  PsicoApp
//
//  Created by Kenay on 31/03/26.
//

import Foundation

enum PatientStatus: String, Codable, CaseIterable {
    case active = "Ativo"
    case inactive = "Inativo"
}

struct Patient: Identifiable, Codable {
    var id: String
    var psychologistID: String
    
    var name: String
    var email: String
    var phobe: String
    var emergencyContact: String?
    var notes: String?
    
    var status: PatientStatus
    var value: Double
    
    var createdAt: Date
    
    var blockedBySystem: Bool?
    
    var initials: String {
        name.components(separatedBy: " ").prefix(2).compactMap { $0.first }.map { String($0) }.joined().uppercased()
    }
}
