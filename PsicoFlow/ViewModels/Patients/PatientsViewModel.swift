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
    
    private let repository: PatientRepositoryProtocol
    private var pacientesListener: ListenerRegistration?
    
    init(repository: PatientRepositoryProtocol = PatientFirebaseRepository()) {
        self.repository = repository
    }
    
    deinit {
        pacientesListener?.remove()
    }
    
    /// Retorna a lista de pacientes filtrada com base no texto de busca atual.
    var pacientesFiltrados: [Patient] {
        if searchText.isEmpty {
            return pacientes
        } else {
            return pacientes.filter { $0.nome.localizedCaseInsensitiveContains(searchText) }
        }
    }
    
    /// Verifica se o usuário atingiu o limite de 5 pacientes do plano gratuito.
    var limitePlanoFreeAtingido: Bool {
        return pacientes.count >= 5
    }
    
    /// Inicia a escuta em tempo real (Offline-First) dos pacientes no Firebase.
    func carregarPacientes(userId: String) {
        guard !userId.isEmpty else { return }
        
        // Remove listener pré-existente para evitar duplicidades
        pacientesListener?.remove()
        
        if let firebaseRepo = repository as? PatientFirebaseRepository {
            pacientesListener = firebaseRepo.escutarPacientes(userId: userId) { [weak self] novosPacientes in
                guard let self = self else { return }
                
                // Atualiza a UI de forma fluida usando animação
                withAnimation(.easeInOut(duration: 0.4)) {
                    self.pacientes = novosPacientes
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
