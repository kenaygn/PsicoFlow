//
//  Session.swift
//  PsicoApp
//
//  Created by Kenay on 31/03/26.
//

import Foundation
import SwiftUI

enum SessionStatus: String, Codable, CaseIterable {
    case completed = "Realizada"
    case cancelled = "Cancelada"
    case postponed = "Adiada"
    case scheduled = "Agendada"
}

enum Modality: String, Codable {
    case online = "Online"
    case inPerson = "Presencial"
}

struct Session: Identifiable, Codable {
    var id: String
    var psychologistID: String
    var patientID: String
    
    var fixedSessionID: String?
    
    var sessionDate: Date
    var status: SessionStatus
    var modality: Modality
    var startTime: String // "14:00"

}
