//
//  SessionActivityAttributes.swift
//  PsicoFlow
//
//  Created by Kenay on 13/08/26.
//

import Foundation
import ActivityKit

public struct SessionActivityAttributes: ActivityAttributes {
    
    // Permite que o app mude a mensagem de status se precisar (ex: "Paciente aguardando")
    public struct ContentState: Codable, Hashable {
        var statusMensagem: String
    }

    var nomePaciente: String
    var modalidade: String // Ex: "Online" ou "Presencial"
    var isFixa: Bool       // true = Fixa (Rosa), false = Avulsa (Laranja)
    var horaInicio: String // Ex: "14:00"
}
