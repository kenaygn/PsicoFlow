//
//  NewSessionViewModel.swift
//  PsicoFlow
//
//  Created by Kenay on 13/04/26.
//

import Foundation
import Combine

class NewSessionViewModel: ObservableObject {
    // --- ESTADOS DA TELA ---
    @Published var pacientesDisponiveis: [Patient] = []
    
    // Campos do Formulário
    @Published var pacienteSelecionadoID: String = ""
    @Published var isFixedSession: Bool = false
    
    // Se for Avulsa
    @Published var selectedDate: Date = Date()
    
    // Se for Fixa (1 = Dom, 2 = Seg... 7 = Sáb)
    @Published var selectedWeekday: Int = Calendar.current.component(.weekday, from: Date())
    
  // Lista completa escondida (privada)
    private let todosHorarios: [String] = [
        "07:00", "08:00", "09:00", "10:00", "11:00", "12:00",
        "13:00", "14:00", "15:00", "16:00", "17:00", "18:00", "19:00", "20:00", "21:00", "22:00"
    ]
    
    @Published var selectedTime: String = "08:00"
    
    // Lista que vai alimentar o Picker (SÓ OS LIVRES)
    var horariosLivres: [String] {
        if isFixedSession {
            let regrasNoMesmoDia = fixedSessionRepository.fetchSessoesFixas().filter { $0.diaDaSemana == selectedWeekday }
            let ocupados = regrasNoMesmoDia.map { $0.horaInicio }
            // Retorna tudo que NÃO ESTÁ nos ocupados
            return todosHorarios.filter { !ocupados.contains($0) }
            
        } else {
            let sessoesNoMesmoDia = sessionRepository.fetchSessoes().filter {
                Calendar.current.isDate($0.dataDaSessão, inSameDayAs: selectedDate) &&
                $0.status != .cancelada 
            }
            let ocupados = sessoesNoMesmoDia.map { $0.horaInicio }
            // Retorna tudo que NÃO ESTÁ nos ocupados
            return todosHorarios.filter { !ocupados.contains($0) }
        }
    }
    
    // Trava de Segurança: Se o usuário mudar o dia e o horário que estava marcado na tela
    // acabar ficando ocupado no novo dia, o app muda a seleção sozinho para o 1º horário livre.
    func atualizarSelecaoDeHorario() {
        if !horariosLivres.contains(selectedTime) {
            selectedTime = horariosLivres.first ?? ""
        }
    }
    
    @Published var selectedModalidade: Modalidade = .presencial
    
    // Repositórios & Serviços
    private let patientRepository: PatientRepositoryProtocol
    private let sessionRepository: SessionRepositoryProtocol
    private let fixedSessionRepository: FixedSessionRepositoryProtocol
    private let generatorService = SessionGeneratorService()
    
// INJEÇÃO DE DEPENDÊNCIA COM DADOS INICIAIS
    init(
        dataSugerida: Date = Date(),
        horarioSugerido: String = "08:00",
        patientRepository: PatientRepositoryProtocol = MockPatientRepository(),
        sessionRepository: SessionRepositoryProtocol = MockSessionRepository(),
        fixedSessionRepository: FixedSessionRepositoryProtocol = MockFixedSessionRepository()
    ) {
        self.patientRepository = patientRepository
        self.sessionRepository = sessionRepository
        self.fixedSessionRepository = fixedSessionRepository
        
        // 👇 APLICA AS SUGESTÕES QUE VIERAM DA TELA ANTERIOR
        self.selectedDate = dataSugerida
        self.selectedTime = horarioSugerido
        
        // Se o usuário resolver ligar a chavinha de "Sessão Fixa", já pega o dia da semana correto também!
        self.selectedWeekday = Calendar.current.component(.weekday, from: dataSugerida)
        
        carregarPacientes()
    }
    
    private func carregarPacientes() {
        self.pacientesDisponiveis = patientRepository.fetchPacientes().filter { $0.status == .ativo }
        if let primeiro = pacientesDisponiveis.first {
            self.pacienteSelecionadoID = primeiro.id
        }
    }
    
    var horaFormatada: String {
        return selectedTime
    }
    
    // MARK: - LÓGICA DE SALVAR
    func salvarSessao() {
        guard let paciente = pacientesDisponiveis.first(where: { $0.id == pacienteSelecionadoID }) else { return }
        
        if isFixedSession {
            // 1. CRIA A FÔRMA (A REGRA)
            let novaRegra = FixedSession(
                id: "fix_\(UUID().uuidString)",
                psicologoID: paciente.psicologoID,
                pacienteID: paciente.id,
                diaDaSemana: selectedWeekday,
                horaInicio: horaFormatada,
                modalidade: selectedModalidade
            )
            
            // 👇 SALVA A REGRA NO BANCO
            fixedSessionRepository.salvarSessaoFixa(novaRegra)
            
            // 2. CHAMA O ROBÔ PARA GERAR AS SESSÕES (Do mês atual até o fim do próximo mês)
            let dataFim = generatorService.ultimoDiaDoProximoMes()
            let sessoesGeradas = generatorService.gerarSessoes(para: novaRegra, dataFim: dataFim)
            
            // 3. SALVA AS SESSÕES FILHAS NO BANCO
            for sessao in sessoesGeradas {
                sessionRepository.salvarSessao(sessao)
            }
            
            print("✅ Regra criada e \(sessoesGeradas.count) sessões geradas até o fim do mês que vem!")
            
        } else {
            // CRIA APENAS UM EVENTO ÚNICO
            let sessaoUnica = Session(
                id: "sess_\(UUID().uuidString)",
                psicologoID: paciente.psicologoID,
                pacienteID: paciente.id,
                sessaoFixaID: nil,
                dataDaSessão: selectedDate,
                status: .agendada,
                modalidade: selectedModalidade,
                horaInicio: horaFormatada
            )
            
            // 👇 SALVA A SESSÃO AVULSA NO BANCO
            sessionRepository.salvarSessao(sessaoUnica)
            
            print("✅ Sessão avulsa criada para o dia: \(sessaoUnica.dataDaSessão)")
        }
    }
}
