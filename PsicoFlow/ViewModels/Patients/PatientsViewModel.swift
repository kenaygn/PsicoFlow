//
//  PatientsViewModel.swift
//  PsicoApp
//
//  Created by Kenay on 04/04/26.
//

import Foundation
import SwiftUI
import Combine
import FirebaseFirestore

class PatientsViewModel: ObservableObject {
    
    @Published var pacientes: [Patient] = []
    @Published var searchText: String = ""
    @Published var isUsuarioPremium: Bool = false
    
    private let repository: PatientRepositoryProtocol
    private let userRepository: UserRepositoryProtocol
    
    private var pacientesListener: ListenerRegistration?
    private var userListener: ListenerRegistration?
    
    init(
        repository: PatientRepositoryProtocol = PatientFirebaseRepository(),
        userRepository: UserRepositoryProtocol = UserFirebaseRepository()
    ) {
        self.repository = repository
        self.userRepository = userRepository
    }
    
    deinit {
        pacientesListener?.remove()
        userListener?.remove()
    }
    
    /// Retorna a lista de pacientes filtrada com base no texto de busca atual.
    var pacientesFiltrados: [Patient] {
        if searchText.isEmpty {
            return pacientes
        } else {
            return pacientes.filter { $0.nome.localizedCaseInsensitiveContains(searchText) }
        }
    }
    
    /// Conta quantos pacientes estão com o status ativo no momento.
    var numeroDePacientesAtivos: Int {
        return pacientes.filter { $0.status == .ativo }.count
    }
    
    /// Verifica se o usuário atingiu o limite de 5 pacientes do plano gratuito.
    var limitePlanoFreeAtingido: Bool {
        if isUsuarioPremium { return false } // 👈 Regra dinâmica
        return numeroDePacientesAtivos >= 5 // 👈 Agora usa apenas os ativos
    }
    
    /// Inicia a escuta em tempo real (Offline-First) dos pacientes no Firebase.
    func carregarPacientes(userId: String) {
        guard !userId.isEmpty else { return }
        
        // Remove listener pré-existente para evitar duplicidades
        pacientesListener?.remove()
        userListener?.remove()
        
        if let firebaseRepo = repository as? PatientFirebaseRepository {
            pacientesListener = firebaseRepo.escutarPacientes(userId: userId) { [weak self] novosPacientes in
                guard let self = self else { return }
                
                // Atualiza a UI de forma fluida usando animação
                withAnimation(.easeInOut(duration: 0.4)) {
                    self.pacientes = novosPacientes
                }
            }
        }
        
        if let userRepo = userRepository as? UserFirebaseRepository {
            userListener = userRepo.escutarUsuario(uid: userId) { [weak self] usuarioAtualizado in
                guard let self = self else { return }
                withAnimation(.easeInOut(duration: 0.4)) {
                    self.isUsuarioPremium = usuarioAtualizado?.premium ?? false
                }
            }
        }
    }
    
    /// Envia o paciente modificado para o repositório (Atualização Otimista).
    func atualizarPaciente(_ pacienteEditado: Patient, userId: String) {
        // Atualização otimista imediata na lista local
        if let index = pacientes.firstIndex(where: { $0.id == pacienteEditado.id }) {
            withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                pacientes[index] = pacienteEditado
            }
        }
        
        Task {
            do {
                try await repository.atualizarPaciente(pacienteEditado, userId: userId)
            } catch {
                print("Erro ao atualizar paciente: \(error.localizedDescription)")
            }
        }
    }
    
    /// Persiste um novo paciente no repositório. O listener atualizará a listagem automaticamente.
    func adicionarPaciente(_ novoPaciente: Patient, userId: String) {
        Task {
            do {
                try await repository.salvarPaciente(novoPaciente, userId: userId)
            } catch {
                print("Erro ao salvar paciente: \(error.localizedDescription)")
            }
        }
    }
}
