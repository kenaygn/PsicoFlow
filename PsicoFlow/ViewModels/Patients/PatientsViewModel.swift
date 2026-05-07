//
//  PatientsViewModel.swift
//  PsicoApp
//
//  Created by Kenay on 04/04/26.
//

import Foundation
import SwiftUI
import Combine

/// ViewModel responsável por gerenciar o estado da lista de pacientes.
class PatientsViewModel: ObservableObject {
        
    @Published var pacientes: [Patient] = []
    @Published var searchText: String = ""
    
    private let repository: PatientRepositoryProtocol
        
    init(repository: PatientRepositoryProtocol = MockPatientRepository()) {
        self.repository = repository
        carregarPacientes()
    }
        
    /// Retorna a lista de pacientes filtrada com base no texto de busca atual.
    /// Utiliza busca *case-insensitive* para melhorar a experiência do usuário.
    var pacientesFiltrados: [Patient] {
        if searchText.isEmpty {
            return pacientes
        } else {
            return pacientes.filter { $0.nome.localizedCaseInsensitiveContains(searchText) }
        }
    }
        
    /// Busca a lista atualizada de pacientes no repositório e atualiza o estado da View.
    func carregarPacientes() {
        // Note: Em uma implementação com banco de dados real (operações assíncronas),
        // será necessário atualizar este método para utilizar async/await ou Combine,
        // além de tratar possíveis estados de carregamento (Loading) e erros (Error Handling).
        self.pacientes = repository.fetchPacientes()
    }
    
    /// Envia o paciente modificado para o repositório e recarrega o estado.
    func atualizarPaciente(_ pacienteEditado: Patient) {
        repository.atualizarPaciente(pacienteEditado)
        carregarPacientes()
    }
    
    /// Persiste um novo paciente no repositório e atualiza a listagem.
    func adicionarPaciente(_ novoPaciente: Patient) {
        repository.salvarPaciente(novoPaciente)
        carregarPacientes()
    }
}
