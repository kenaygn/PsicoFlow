//
//  SessionRepositoryProtocol.swift
//  PsicoFlow
//
//  Created by Kenay on 06/04/26.
//

import Foundation

protocol SessionRepositoryProtocol {
    func fetchSessoes(userId: String) async throws -> [Session]
    func atualizarSessao(_ sessao: Session, userId: String) async throws
    func salvarSessao(_ sessao: Session, userId: String) async throws
    func deletarSessao(id: String, userId: String) async throws
}
