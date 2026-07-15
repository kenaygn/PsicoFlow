//
//  UserRepositoryProtocol.swift
//  PsicoFlow
//
//  Created by Kenay on 15/07/26.
//

import Foundation

protocol UserRepositoryProtocol {
    func fetchUser(uid: String) async throws -> User?
    func saveUser(user: User) async throws
    func updateUser(user: User) async throws
}
