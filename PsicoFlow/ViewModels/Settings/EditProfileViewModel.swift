//
//  EditProfileViewModel.swift
//  PsicoFlow
//
//  Created by Kenay on 08/06/26.
//

import Foundation
import SwiftUI
import Combine
import FirebaseAuth

@MainActor
class EditProfileViewModel: ObservableObject {
    private var authManager: AuthManager
    private let userRepository: UserRepositoryProtocol
    private let sessionRepository: SessionRepositoryProtocol
    private let fixedSessionRepository: FixedSessionRepositoryProtocol
    
    @Published var nome: String = ""
    @Published var crp: String = ""
    
    @Published var horaInicioExpediente: String = "07:00"
    @Published var horaFimExpediente: String = "22:00"
    
    @Published var senhaAtual: String = ""
    @Published var novaSenha: String = ""
    
    @Published var errorMessage: String? = nil
    @Published var isUpdating: Bool = false
    
    let horariosDisponiveis: [String] = (0...23).map { String(format: "%02d:00", $0) }
    
    var isEmailProvider: Bool {
        guard let user = Auth.auth().currentUser else { return false }
        return user.providerData.contains { $0.providerID == "password" }
    }
    
    init(authManager: AuthManager,
         userRepository: UserRepositoryProtocol = UserFirebaseRepository(),
         sessionRepository: SessionRepositoryProtocol = SessionFirebaseRepository(),
         fixedSessionRepository: FixedSessionRepositoryProtocol = FixedSessionFirebaseRepository()) {
        self.authManager = authManager
        self.userRepository = userRepository
        self.sessionRepository = sessionRepository
        self.fixedSessionRepository = fixedSessionRepository
        carregarDadosAtuais()
    }
    
    var temAlteracoes: Bool {
        guard let user = authManager.usuarioAtual else { return false }
        
        let dadosMudaram = nome != user.nome ||
                           crp != user.crp ||
                           horaInicioExpediente != user.horaInicioExpediente ||
                           horaFimExpediente != user.horaFimExpediente
        
        let tentandoMudarSenha = isEmailProvider && !novaSenha.isEmpty && !senhaAtual.isEmpty
        
        let camposValidos = !nome.trimmingCharacters(in: .whitespaces).isEmpty
        
        let inicioInt = Int(horaInicioExpediente.prefix(2)) ?? 0
        let fimInt = Int(horaFimExpediente.prefix(2)) ?? 0
        let horarioValido = inicioInt < fimInt
        
        return (dadosMudaram || tentandoMudarSenha) && camposValidos && horarioValido
    }
    
    private func carregarDadosAtuais() {
        guard let user = authManager.usuarioAtual else { return }
        self.nome = user.nome
        self.crp = user.crp
        self.horaInicioExpediente = user.horaInicioExpediente
        self.horaFimExpediente = user.horaFimExpediente
    }
    
    // MARK: - Validação Poderosa de Horários
    private func verificarSessoesForaDoExpediente() async -> Bool {
        guard let userId = authManager.usuarioID else { return false }
        
        do {
            // Busca todas as sessões e regras do banco simultaneamente
            async let sessoes = sessionRepository.fetchSessoes(userId: userId)
            async let regrasFixas = fixedSessionRepository.fetchSessoesFixas(userId: userId)
            
            let todasSessoes = try await sessoes
            let todasRegras = try await regrasFixas
            
            let inicioDeHoje = Calendar.current.startOfDay(for: Date())
            
            let sessoesAtivas = todasSessoes.filter { $0.sessionDate >= inicioDeHoje && $0.status != .cancelled }
            
            let novoInicioInt = Int(horaInicioExpediente.prefix(2)) ?? 0
            let novoFimInt = Int(horaFimExpediente.prefix(2)) ?? 23
            
            // Verifica se há conflito nas Sessões (Geradas e Avulsas)
            let conflitoSessoes = sessoesAtivas.contains { sessao in
                let horaInt = Int(sessao.startTime.prefix(2)) ?? 0
                return horaInt < novoInicioInt || horaInt > novoFimInt
            }
            
            // Verifica se há conflito nas Regras (Contratos Fixos)
            let conflitoRegras = todasRegras.contains { regra in
                let horaInt = Int(regra.startTime.prefix(2)) ?? 0
                return horaInt < novoInicioInt || horaInt > novoFimInt
            }
            
            return conflitoSessoes || conflitoRegras
            
        } catch {
            print("Erro ao buscar sessões para validação: \(error)")
            return false // Libera em caso de erro para não travar o app do usuário
        }
    }
    
    func salvarAlteracoes() async -> Bool {
        isUpdating = true
        defer { isUpdating = false }
        
        let temSessoesFora = await verificarSessoesForaDoExpediente()
        if temSessoesFora {
            self.errorMessage = "Você possui sessões agendadas fora do novo horário de expediente. Reagende ou cancele essas sessões antes de alterar os limites."
            return false
        }
        
        if let currentUser = authManager.usuarioAtual {
            var userAtualizado = currentUser
            userAtualizado.nome = self.nome
            userAtualizado.crp = self.crp
            userAtualizado.horaInicioExpediente = self.horaInicioExpediente
            userAtualizado.horaFimExpediente = self.horaFimExpediente
            
            do {
                try await userRepository.updateUser(user: userAtualizado)
                authManager.usuarioAtual = userAtualizado
            } catch {
                self.errorMessage = "Erro ao atualizar os dados: \(error.localizedDescription)"
                return false
            }
        }
        
        if isEmailProvider && !novaSenha.isEmpty && !senhaAtual.isEmpty {
            do {
                guard let user = Auth.auth().currentUser, let email = user.email else { return false }
                let credential = EmailAuthProvider.credential(withEmail: email, password: senhaAtual)
                try await user.reauthenticate(with: credential)
                try await user.updatePassword(to: novaSenha)
                self.senhaAtual = ""
                self.novaSenha = ""
            } catch {
                self.errorMessage = "Erro ao alterar a senha. Verifique se a 'Senha Atual' está correta."
                return false
            }
        }
        
        return true
    }
}
