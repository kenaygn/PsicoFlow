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
    
    @Published var carregamentoInicialConcluido: Bool = false
    
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
    
    var pacientesFiltrados: [Patient] {
        let listaFiltrada = searchText.isEmpty ? pacientes : pacientes.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
        
        return listaFiltrada.sorted { (paciente1, paciente2) in
            if paciente1.status == .active && paciente2.status != .active {
                return true
            }
            else if paciente1.status != .active && paciente2.status == .active {
                return false
            }
            else {
                return paciente1.name.localizedCaseInsensitiveCompare(paciente2.name) == .orderedAscending
            }
        }
    }
    
    var numeroDePacientesAtivos: Int {
        return pacientes.filter { $0.status == .active }.count
    }
    
    var limitePlanoFreeAtingido: Bool {
        if isUsuarioPremium { return false } //
        return numeroDePacientesAtivos >= 5 //
    }
    
    func carregarPacientes(userId: String) {
        guard !userId.isEmpty else { return }
        
        pacientesListener?.remove()
        userListener?.remove()
        
        if let firebaseRepo = repository as? PatientFirebaseRepository {
            pacientesListener = firebaseRepo.escutarPacientes(userId: userId) { [weak self] novosPacientes in
                guard let self = self else { return }

                self.pacientes = novosPacientes
                self.carregamentoInicialConcluido = true
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
    
    func atualizarPaciente(_ pacienteEditado: Patient, userId: String) {
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
