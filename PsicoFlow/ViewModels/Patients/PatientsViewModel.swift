//
//  PatientsViewModel.swift
//  PsicoApp
//
//  Created by Kenay on 04/04/26.
//

import Foundation
import SwiftUI
import Combine

class PatientsViewModel: ObservableObject {
    @Published var pacientes: [Patient] = []
    @Published var searchText: String = ""
    
    // O nosso "Gerente" de dados
    private let repository: PatientRepositoryProtocol
    
    // INJEÇÃO DE DEPENDÊNCIA:
    // Nós passamos o repositório pelo Init. Por padrão, ele usa o Mock,
    // mas no futuro você poderá passar um FirebasePatientRepository() aqui!
    init(repository: PatientRepositoryProtocol = MockPatientRepository()) {
        self.repository = repository
        carregarPacientes()
    }
    
    func carregarPacientes() {
        // A ViewModel não sabe mais o que é "MockData". Ela só pede os dados.
        self.pacientes = repository.fetchPacientes()
    }
    
    var pacientesFiltrados: [Patient] {
        if searchText.isEmpty {
            return pacientes
        } else {
            return pacientes.filter { $0.nome.localizedCaseInsensitiveContains(searchText) }
        }
    }
    
    func atualizarPaciente(_ pacienteEditado: Patient) {
        // 1. Manda o banco de dados atualizar
        repository.atualizarPaciente(pacienteEditado)
        
        // 2. Recarrega a lista para a tela refletir a mudança
        carregarPacientes()
    }
    
    func adicionarPaciente(_ novoPaciente: Patient) {
        // 1. Manda o banco de dados salvar
        repository.salvarPaciente(novoPaciente)
        
        // 2. Recarrega a lista
        carregarPacientes()
    }
}
