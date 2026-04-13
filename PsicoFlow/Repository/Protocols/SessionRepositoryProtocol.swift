//
//  SessionRepositoryProtocol.swift
//  PsicoFlow
//
//  Created by Kenay on 06/04/26.
//

import Foundation

// O Contrato para Sessões
protocol SessionRepositoryProtocol {
    func fetchSessoes() -> [Session]
    func atualizarSessao(_ sessao: Session)
    func salvarSessao(_ sessao: Session)
}
