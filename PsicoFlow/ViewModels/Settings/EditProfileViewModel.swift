//
//  EditProfileViewModel.swift
//  PsicoFlow
//
//  Created by Kenay on 08/06/26.
//

import Foundation
import SwiftUI
import Combine

class EditProfileViewModel: ObservableObject {
    private var settingsViewModel: SettingsViewModel
    
    @Published var nome: String = ""
    @Published var email: String = ""
    @Published var crp: String = ""
    
    @Published var senhaAtual: String = ""
    @Published var novaSenha: String = ""
    @Published var confirmarNovaSenha: String = ""
    
    var senhasDivergem: Bool {
        !confirmarNovaSenha.isEmpty && novaSenha != confirmarNovaSenha
    }
    
    init(settingsViewModel: SettingsViewModel) {
        self.settingsViewModel = settingsViewModel
        carregarDadosAtuais()
    }
    
    var temAlteracoes: Bool {
        let dadosMudaram = nome != settingsViewModel.currentUser.nome ||
        email != settingsViewModel.currentUser.email ||
        crp != settingsViewModel.currentUser.crp
        
        let tentandoMudarSenha = !senhaAtual.isEmpty || !novaSenha.isEmpty || !confirmarNovaSenha.isEmpty
        
        var senhasValidas = true
        if tentandoMudarSenha {
            senhasValidas = !senhaAtual.isEmpty &&
            !novaSenha.isEmpty &&
            (novaSenha == confirmarNovaSenha)
        }
        
        let camposValidos = !nome.trimmingCharacters(in: .whitespaces).isEmpty &&
        !email.trimmingCharacters(in: .whitespaces).isEmpty
        
        return (dadosMudaram || tentandoMudarSenha) && camposValidos && senhasValidas
    }
    
    private func carregarDadosAtuais() {
        self.nome = settingsViewModel.currentUser.nome
        self.email = settingsViewModel.currentUser.email
        self.crp = settingsViewModel.currentUser.crp
    }
    
    func salvarAlteracoes() {
        // 1. Salva os dados normais no banco de dados...
        settingsViewModel.currentUser.nome = nome
        // ...
        
        // 2. Tenta mudar a senha no Firebase
        if !senhaAtual.isEmpty && novaSenha == confirmarNovaSenha {
            // Código do Firebase:
            // Auth.auth().signIn(withEmail: email, password: senhaAtual) { ... }
            // Auth.auth().currentUser?.updatePassword(to: novaSenha) { erro in
            //     if erro != nil { mostrarAlerta("Sua senha atual está incorreta!") }
            // }
        }
    }
}
