//
//  FixedSession.swift
//  PsicoApp
//
//  Created by Kenay on 31/03/26.
//

import Foundation

struct FixedSession: Identifiable, Codable {
    var id: String
    var psicologoID: String
    var pacienteID: String
    
    var diaDaSemana: Int // 1 = Domingo, 2 = Segunda...
    var horaInicio: String // "14:00"
    var modalidade: Modality

}
