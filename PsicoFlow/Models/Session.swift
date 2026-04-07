//
//  Session.swift
//  PsicoApp
//
//  Created by Kenay on 31/03/26.
//

import Foundation
import SwiftUI

enum SessionStatus: String, Codable, CaseIterable {
    case realizada = "Realizada"
    case cancelada = "Cancelada"
    case adiada = "Adiada"
    case agendada = "Agendada"
}

enum Modalidade: String, Codable {
    case online = "Online"
    case presencial = "Presencial"
}

struct Session: Identifiable, Codable {
    var id: String
    var psicologoID: String
    var pacienteID: String
    
    var sessaoFixaID: String?
    
    var dataDaSessão: Date
    var status: SessionStatus
    var modalidade: Modalidade
    var horaInicio: String // "14:00"

}
