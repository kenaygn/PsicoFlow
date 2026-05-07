//
//  MockEvolutionRepository.swift
//  PsicoFlow
//
//  Created by Kenay on 06/04/26.
//

import Foundation

class MockEvolutionRepository: EvolutionRepositoryProtocol {
    
    func fetchEvolucoes(paraPacienteID pacienteID: String) -> [Evolution] {
        return MockData.evolucoesExemplo.filter { $0.pacienteID == pacienteID }
    }
    
    func salvarEvolucao(_ evolucao: Evolution) {
        MockData.evolucoesExemplo.append(evolucao)
    }
}
