//
//  Untitled.swift
//  PsicoFlow
//
//  Created by Kenay on 06/04/26.
//

import Foundation

class MockSessionRepository: SessionRepositoryProtocol {
    func fetchSessoes() -> [Session] {
        return MockData.sessoesExemplo
    }
    
    func atualizarSessao(_ sessao: Session) {
        if let index = MockData.sessoesExemplo.firstIndex(where: { $0.id == sessao.id }) {
            MockData.sessoesExemplo[index] = sessao
        }
    }
    
    func salvarSessao(_ sessao: Session) {
            MockData.sessoesExemplo.append(sessao)
        }
}
