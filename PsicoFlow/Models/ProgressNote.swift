//
//  Evolution.swift
//  PsicoApp
//
//  Created by Kenay on 31/03/26.
//

import Foundation

struct ProgressNote: Identifiable, Codable {
    var id: String
    var psychologistID: String
    var patientID: String
    
    var date: Date
    var content: String // Texto da nota
}
