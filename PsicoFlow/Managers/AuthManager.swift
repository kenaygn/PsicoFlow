//
//  AuthManager.swift
//  PsicoFlow
//
//  Created by Kenay on 02/06/26.
//

import Foundation
import Combine

/// Gerenciador temporário (Mock) de estado de autenticação.
/// No futuro, esta classe fará a ponte com o Firebase Auth.
class AuthManager: ObservableObject {
    // Mantemos como 'true' por padrão agora para que você possa testar e acessar o app livremente.
    // Quando formos fazer o Login real, isso começará como 'false'.
    @Published var usuarioLogado: Bool = true
}
