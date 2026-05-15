//
//  MockFixedSessionRepository.swift
//  PsicoFlow
//
//  Created by Kenay on 13/04/26.
//

import Foundation

class MockFixedSessionRepository: FixedSessionRepositoryProtocol {
    func fetchSessoesFixas() -> [FixedSession] {
        return MockData.sessoesFixasExemplo
    }
    
    func salvarSessaoFixa(_ sessaoFixa: FixedSession) {
        MockData.sessoesFixasExemplo.append(sessaoFixa)
    }
    
    func atualizarSessaoFixa(_ sessaoFixa: FixedSession) {
        if let index = MockData.sessoesFixasExemplo.firstIndex(where: { $0.id == sessaoFixa.id }) {
            MockData.sessoesFixasExemplo[index] = sessaoFixa
        }
    }
    
    func deletarSessaoFixa(id: String) {
        MockData.sessoesFixasExemplo.removeAll(where: { $0.id == id })
    }
}
