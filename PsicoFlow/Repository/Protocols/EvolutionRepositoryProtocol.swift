//
//  EvolutionRepositoryProtocol.swift
//  PsicoFlow
//
//  Created by Kenay on 06/04/26.
//

import Foundation

protocol EvolutionRepositoryProtocol {
    func fetchEvolucoes(paraPacienteID pacienteID: String, userId: String) async throws -> [ProgressNote]
    func salvarEvolucao(_ evolucao: ProgressNote, userId: String) async throws
    func atualizarEvolucao(_ evolucao: ProgressNote, userId: String) async throws
    func deletarEvolucao(id: String, userId: String) async throws
}
