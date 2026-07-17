//
//  PatientRepositoryProtocol.swift
//  PsicoFlow
//
//  Created by Kenay on 06/04/26.
//

import Foundation

protocol PatientRepositoryProtocol {
    func fetchPacientes(userId: String) async throws -> [Patient]
    func salvarPaciente(_ paciente: Patient, userId: String) async throws
    func atualizarPaciente(_ paciente: Patient, userId: String) async throws
}
