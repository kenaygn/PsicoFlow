//
//  MockPatientRepository.swift
//  PsicoFlow
//
//  Created by Kenay on 06/04/26.
//

import Foundation

// O nosso banco de dados temporário
class MockPatientRepository: PatientRepositoryProtocol {
    
    func fetchPacientes() -> [Patient] {
        return MockData.listaPacientes
    }
    
    func salvarPaciente(_ paciente: Patient) {
        MockData.listaPacientes.append(paciente)
    }
    
    func atualizarPaciente(_ paciente: Patient) {
        if let index = MockData.listaPacientes.firstIndex(where: { $0.id == paciente.id }) {
            MockData.listaPacientes[index] = paciente
        }
    }
}
