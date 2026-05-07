//
//  FixedSessionRepositoryProtocol.swift
//  PsicoFlow
//
//  Created by Kenay on 13/04/26.
//

import Foundation

protocol FixedSessionRepositoryProtocol {
    func fetchSessoesFixas() -> [FixedSession]
    func salvarSessaoFixa(_ sessaoFixa: FixedSession)
    func atualizarSessaoFixa(_ sessaoFixa: FixedSession)
}
