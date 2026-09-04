//
//  SessionRepositoryProtocol.swift
//  PsicoFlow
//
//  Created by Kenay on 06/04/26.
//

import Foundation

protocol SessionRepositoryProtocol {
    func fetchSessions(userId: String) async throws -> [Session]
    func updateSession(_ session: Session, userId: String) async throws
    func saveSession(_ session: Session, userId: String) async throws
    func deleteSession(id: String, userId: String) async throws
}
