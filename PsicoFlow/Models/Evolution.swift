//
//  Evolution.swift
//  PsicoApp
//
//  Created by Kenay on 31/03/26.
//

import Foundation

struct Evolution: Identifiable, Codable {
    var id: String
    var psicologoID: String
    var pacienteID: String
    
    var data: Date
    var conteudo: String // Texto da nota
}
