//
//  PatientRepositoryProtocol.swift
//  PsicoFlow
//
//  Created by Kenay on 06/04/26.
//

import Foundation

protocol PatientRepositoryProtocol {
    func fetchPacientes() -> [Patient]
    func salvarPaciente(_ paciente: Patient)
    func atualizarPaciente(_ paciente: Patient)
}
