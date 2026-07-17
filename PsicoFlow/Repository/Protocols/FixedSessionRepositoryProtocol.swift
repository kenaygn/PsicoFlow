//
//  FixedSessionRepositoryProtocol.swift
//  PsicoFlow
//
//  Created by Kenay on 13/04/26.
//

import Foundation

protocol FixedSessionRepositoryProtocol {
    func fetchSessoesFixas(userId: String) async throws -> [FixedSession]
    func salvarSessaoFixa(_ sessaoFixa: FixedSession, userId: String) async throws
    func atualizarSessaoFixa(_ sessaoFixa: FixedSession, userId: String) async throws
    func deletarSessaoFixa(id: String, userId: String) async throws
}
