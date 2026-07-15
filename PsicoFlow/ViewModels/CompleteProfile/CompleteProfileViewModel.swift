//
//  CompleteProfileViewModel.swift
//  PsicoFlow
//
//  Created by Kenay on 15/07/26.
//

import Foundation
import SwiftUI
import Combine

enum PassoCadastro: Int, CaseIterable {
    case introducao = 0
    case nome = 1
    case crp = 2
    case horarios = 3
    case sucesso = 4
}

class CompleteProfileViewModel: ObservableObject {
    @Published var passoAtual: PassoCadastro = .introducao
    
    @Published var nome = ""
    @Published var crp = ""
    @Published var horaInicio = "07:00"
    @Published var horaFim = "22:00"
    
    let opcoesHorarios = (0...23).map { String(format: "%02d:00", $0) }
    
    var formularioValido: Bool {
        let nomePreenchido = !nome.trimmingCharacters(in: .whitespaces).isEmpty
        let crpPreenchido = !crp.trimmingCharacters(in: .whitespaces).isEmpty
        let horarioValido = horaInicio < horaFim
        
        return nomePreenchido && crpPreenchido && horarioValido
    }
    
    func avancarPasso() {
        if let proximo = PassoCadastro(rawValue: passoAtual.rawValue + 1) {
            passoAtual = proximo
        }
    }
    
    func finalizarCadastro() {
        //TODO: Salvar no Firebase
        // Lógica futura para salvar no Firebase
        print("Salvando: \(nome), \(crp), \(horaInicio) às \(horaFim)")
        avancarPasso()
    }
}
