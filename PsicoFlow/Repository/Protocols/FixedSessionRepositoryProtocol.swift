//
//  FixedSessionRepositoryProtocol.swift
//  PsicoFlow
//
//  Created by Kenay on 13/04/26.
//

import Foundation

protocol FixedSessionRepositoryProtocol {
    func fetchFixedSessions(userId: String) async throws -> [FixedSession]
    func saveFixedSession(_ fixedSession: FixedSession, userId: String) async throws
    func updateFixedSession(_ fixedSession: FixedSession, userId: String) async throws
    func deleteFixedSession(id: String, userId: String) async throws
}
