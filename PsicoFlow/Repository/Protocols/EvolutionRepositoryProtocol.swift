//
//  EvolutionRepositoryProtocol.swift
//  PsicoFlow
//
//  Created by Kenay on 06/04/26.
//

import Foundation

// O "Contrato" para o banco de dados de evoluções
protocol EvolutionRepositoryProtocol {
    // Buscar evoluções filtrando apenas as de um paciente específico
    func fetchEvolucoes(paraPacienteID pacienteID: String) -> [Evolution]
    
    // Salvar uma nova evolução
    func salvarEvolucao(_ evolucao: Evolution)
}
