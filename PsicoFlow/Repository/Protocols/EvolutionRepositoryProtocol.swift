//
//  EvolutionRepositoryProtocol.swift
//  PsicoFlow
//
//  Created by Kenay on 06/04/26.
//

import Foundation

protocol EvolutionRepositoryProtocol {
    func fetchEvolucoes(paraPacienteID pacienteID: String, userId: String) async throws -> [Evolution]
    func salvarEvolucao(_ evolucao: Evolution, userId: String) async throws
}
