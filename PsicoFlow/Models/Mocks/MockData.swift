//
//  MockData.swift
//  PsicoApp
//
//  Created by Kenay on 31/03/26.
//

import Foundation

struct MockData {
    
    static let psicologoPrincipal = User(
        id: "user_dev_01",
        nome: "Dr. Psicólogo",
        email: "contato@mindflow.com.br",
        crp: "06/123456",
        premium: false,
        criadoEm: Date()
    )
    
    static var listaPacientes: [Patient] = [
            Patient(id: "p1", psicologoID: "user_dev_01", nome: "Ana Carolina Silva", email: "ana@email.com", telefone: "(11) 98765-4321", status: .ativo, valor: 150.0, criadoEm: Date()),
            Patient(id: "p2", psicologoID: "user_dev_01", nome: "Marcos Vinícius Costa", email: "marcos@email.com", telefone: "(11) 91234-5678", status: .ativo, valor: 180.0, criadoEm: Date()),
            Patient(id: "p3", psicologoID: "user_dev_01", nome: "Beatriz Souza", email: "beatriz@email.com", telefone: "(11) 99988-7766", status: .inativo, valor: 130.0, criadoEm: Date())
        ]
    
    static var sessoesExemplo: [Session] = [
        
            // Sessão Agendada
            Session(
                id: "sess_004",
                psicologoID: "user_dev_01",
                pacienteID: "p1", // Ana Carolina
                sessaoFixaID: "fix_ana_001",
                dataDaSessão: Date(),
                status: .agendada,
                modalidade: .presencial,
                horaInicio: "20:00"
            ),
        
        
            // 1. Sessão Realizada (Hoje)
            Session(
                id: "sess_001",
                psicologoID: "user_dev_01",
                pacienteID: "p1", // Ana Carolina
                sessaoFixaID: "fix_ana_001",
                dataDaSessão: Date(),
                status: .realizada,
                modalidade: .presencial,
                horaInicio: "09:00"
            ),
            
            // 2. Outra Sessão Realizada (Hoje, mais tarde)
            Session(
                id: "sess_002",
                psicologoID: "user_dev_01",
                pacienteID: "p2", // Marcos Vinícius
                sessaoFixaID: "fix_marcos_002",
                dataDaSessão: Date(),
                status: .agendada,
                modalidade: .online,
                horaInicio: "14:00"
            ),
            
            // 3. Sessão Adiada (Para amanhã)
            Session(
                id: "sess_003",
                psicologoID: "user_dev_01",
                pacienteID: "p1",
                sessaoFixaID: nil, // Sessão avulsa, sem regra fixa
                dataDaSessão: Calendar.current.date(byAdding: .day, value: 1, to: Date())!,
                status: .adiada,
                modalidade: .presencial,
                horaInicio: "11:00"
            ),
            
            // 4. Sessão Cancelada (Semana passada)
            Session(
                id: "sess_004",
                psicologoID: "user_dev_01",
                pacienteID: "p3", // Beatriz
                sessaoFixaID: "fix_beatriz_003",
                dataDaSessão: Calendar.current.date(byAdding: .day, value: -5, to: Date())!,
                status: .cancelada,
                modalidade: .online,
                horaInicio: "16:30"
            )
        ]

    
    static var sessoesFixasExemplo: [FixedSession] = [
            // Ana Carolina: Toda Segunda às 09:00
            FixedSession(
                id: "fix_ana_001",
                psicologoID: "user_dev_01",
                pacienteID: "p1",
                diaDaSemana: 2, // Segunda-feira
                horaInicio: "09:00",
                modalidade: .presencial
            ),
            
            // Marcos Vinícius: Toda Segunda às 14:00
            FixedSession(
                id: "fix_marcos_002",
                psicologoID: "user_dev_01",
                pacienteID: "p2",
                diaDaSemana: 2,
                horaInicio: "14:00",
                modalidade: .online
            ),
            
            // Beatriz Souza: Toda Quarta às 16:30
            FixedSession(
                id: "fix_beatriz_003",
                psicologoID: "user_dev_01",
                pacienteID: "p3",
                diaDaSemana: 4, // Quarta-feira
                horaInicio: "16:00",
                modalidade: .online
            )
        ]
    
    static var pagamentosExemplo: [MonthlyPayment] = [
            // Pagamento já realizado
            MonthlyPayment(
                id: "pay_001",
                psicologoID: "user_dev_01",
                pacienteID: "p1", // Ana Carolina
                mesReferencia: "2026/03",
                dataPagamento: Date(),
                valor: 400.0, // Ex: 4 sessões de 150
                pago: true
            ),
            
            // Pagamento pendente do mês atual
            MonthlyPayment(
                id: "pay_002",
                psicologoID: "user_dev_01",
                pacienteID: "p2", // Marcos Vinícius
                mesReferencia: "2026/03",
                dataPagamento: nil,
                valor: 720.0, // Ex: 4 sessões de 180
                pago: false
            ),
            
            MonthlyPayment(
                id: "pay_004",
                psicologoID: "user_dev_01",
                pacienteID: "p2", // Marcos Vinícius
                mesReferencia: "2026/06",
                dataPagamento: nil,
                valor: 300.0, // Ex: 4 sessões de 180
                pago: false
            ),
            
            // Pagamento de mês anterior já finalizado
            MonthlyPayment(
                id: "pay_003",
                psicologoID: "user_dev_01",
                pacienteID: "p1",
                mesReferencia: "2026/02",
                dataPagamento: Calendar.current.date(byAdding: .month, value: -1, to: Date())!,
                valor: 600.0,
                pago: true
            )
        ]
    
    static var evolucoesExemplo: [Evolution] = [
            Evolution(
                id: "ev_001",
                psicologoID: "user_dev_01",
                pacienteID: "p1",
                data: Date(),
                conteudo: "Paciente relatou melhora na ansiedade. Trabalhamos técnicas de respiração."
            ),
            Evolution(
                id: "ev_002",
                psicologoID: "user_dev_01",
                pacienteID: "p1",
                data: Date(),
                conteudo: "Paciente desmostrou piora no estado clínico",
            )
        ]
    
}
