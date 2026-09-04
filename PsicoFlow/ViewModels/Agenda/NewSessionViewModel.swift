//
//  NewSessionViewModel.swift
//  PsicoFlow
//
//  Created by Kenay on 13/04/26.
//

import Foundation
import Combine
import os

class NewSessionViewModel: ObservableObject {
    
    private let patientRepository: PatientRepositoryProtocol
    private let sessionRepository: SessionRepositoryProtocol
    private let fixedSessionRepository: FixedSessionRepositoryProtocol
    
    private let generatorService: SessionGeneratorService
    private let availabilityService: AgendaAvailabilityService
    
    @Published var pacientesDisponiveis: [Patient] = []
    @Published var pacienteSelecionadoID: String = ""
    @Published var isFixedSession: Bool = false
    @Published var selectedDate: Date = Date()
    @Published var selectedWeekday: Int = Calendar.current.component(.weekday, from: Date())
    @Published var selectedTime: String = "08:00"
    @Published var selectedModalidade: Modality = .inPerson
    
    @Published var mostrarAlertaConflitoFixo: Bool = false
    
    // Lista de horários agora é @Published para refletir a busca assíncrona
    @Published var horariosLivres: [String] = []
    
    init(
        dataSugerida: Date = Date(),
        horarioSugerido: String = "08:00",
        patientRepository: PatientRepositoryProtocol = PatientFirebaseRepository(),
        sessionRepository: SessionRepositoryProtocol = SessionFirebaseRepository(),
        fixedSessionRepository: FixedSessionRepositoryProtocol = FixedSessionFirebaseRepository()
    ) {
        self.patientRepository = patientRepository
        self.sessionRepository = sessionRepository
        self.fixedSessionRepository = fixedSessionRepository
        
        self.selectedDate = dataSugerida
        self.selectedTime = horarioSugerido
        self.selectedWeekday = Calendar.current.component(.weekday, from: dataSugerida)
        
        self.availabilityService = AgendaAvailabilityService(
            fixedSessionRepository: fixedSessionRepository,
            sessionRepository: sessionRepository
        )
        
        self.generatorService = SessionGeneratorService(
            patientRepository: patientRepository,
            fixedSessionRepository: fixedSessionRepository,
            sessionRepository: sessionRepository
        )
    }
    
    var horaFormatada: String {
        return selectedTime
    }
    
    // Função assíncrona para buscar pacientes
    func carregarPacientes(userId: String) {
        guard !userId.isEmpty else { return }
        
        Task {
            do {
                let pacientesDoBanco = try await patientRepository.fetchPatients(userId: userId)
                await MainActor.run {
                    self.pacientesDisponiveis = pacientesDoBanco.filter { $0.status == .active }
                    if self.pacienteSelecionadoID.isEmpty, let primeiro = self.pacientesDisponiveis.first {
                        self.pacienteSelecionadoID = primeiro.id
                    }
                }
            } catch {
                print("Erro ao carregar pacientes: \(error.localizedDescription)")
            }
        }
    }
    
    // Função assíncrona para calcular horários livres
    func carregarHorariosLivres(userId: String) {
        Task {
            do {
                if isFixedSession {
                    let livresContrato = try await availabilityService.horariosLivresParaContrato(diaDaSemana: selectedWeekday, userId: userId)
                    
                    await MainActor.run {
                        // Se o usuário tentar fixar um horário que já tem dono no contrato:
                        if !self.selectedTime.isEmpty && !livresContrato.contains(self.selectedTime) {
                            self.mostrarAlertaConflitoFixo = true
                            self.isFixedSession = false // Desliga o botão e força voltar para sessão avulsa
                        } else {
                            self.horariosLivres = livresContrato
                            self.atualizarSelecaoDeHorario()
                        }
                    }
                } else {
                    let livresAvulsos = try await availabilityService.horariosLivresParaSessaoAvulsa(data: selectedDate, userId: userId)
                    
                    await MainActor.run {
                        self.horariosLivres = livresAvulsos
                        // Só muda o horário sozinho se o slot atual realmente estiver ocupado no dia
                        if !self.selectedTime.isEmpty && !self.horariosLivres.contains(self.selectedTime) {
                            self.selectedTime = self.horariosLivres.first ?? ""
                        }
                    }
                }
            } catch {
                print("Erro ao carregar horários: \(error.localizedDescription)")
            }
        }
    }
    
    func atualizarSelecaoDeHorario() {
        if !horariosLivres.contains(selectedTime) {
            selectedTime = horariosLivres.first ?? ""
        }
    }
    
    func salvarSessao(userId: String) {
        guard let paciente = pacientesDisponiveis.first(where: { $0.id == pacienteSelecionadoID }) else { return }
        
        Task {
            do {
                if isFixedSession {
                    let novaRegra = FixedSession(
                        id: "fix_\(UUID().uuidString)",
                        psychologistID: userId,
                        patientID: paciente.id,
                        weekday: selectedWeekday,
                        startTime: horaFormatada,
                        modality: selectedModalidade
                    )
                    
                    try await fixedSessionRepository.saveFixedSession(novaRegra, userId: userId)
                    
                    let dataFim = generatorService.lastDayOfNextMonth()
                    let sessoesGeradas = generatorService.generateSessions(for: novaRegra, endDate: dataFim)
                    
                    for sessao in sessoesGeradas {
                        try await sessionRepository.saveSession(sessao, userId: userId)
                    }
                } else {
                    let sessaoUnica = Session(
                        id: "sess_\(UUID().uuidString)",
                        psychologistID: userId,
                        patientID: paciente.id,
                        fixedSessionID: nil,
                        sessionDate: selectedDate,
                        status: .scheduled,
                        modality: selectedModalidade,
                        startTime: horaFormatada
                    )
                    
                    try await sessionRepository.saveSession(sessaoUnica, userId: userId)
                }
            } catch {
                print("Erro ao salvar sessão: \(error.localizedDescription)")
            }
        }
    }
}

