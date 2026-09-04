//
//  FixedSession.swift
//  PsicoApp
//
//  Created by Kenay on 31/03/26.
//

import Foundation

struct FixedSession: Identifiable, Codable {
    var id: String
    var psychologistID: String
    var patientID: String
    
    var weekday: Int // 1 = Domingo, 2 = Segunda...
    var startTime: String // "14:00"
    var modality: Modality

}
