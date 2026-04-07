//
//  FinancesViewModel.swift
//  PsicoFlow
//
//  Created by Kenay on 07/04/26.
//

import Foundation
import Combine

// Enum para controlar o Segmented Picker
enum FinanceViewMode {
    case mensal
    case anual
}

class FinanceViewModel: ObservableObject {
    // Dados brutos do banco
    @Published private var todosPagamentos: [MonthlyPayment] = []
    @Published private var pacientes: [Patient] = []
    
    // Controles de Tela
    @Published var viewMode: FinanceViewMode = .mensal
    @Published var currentDate: Date = Date()
    
    // Repositórios
    private let paymentRepository: PaymentRepositoryProtocol
    private let patientRepository: PatientRepositoryProtocol
    
    init(
        paymentRepository: PaymentRepositoryProtocol = MockPaymentRepository(),
        patientRepository: PatientRepositoryProtocol = MockPatientRepository()
    ) {
        self.paymentRepository = paymentRepository
        self.patientRepository = patientRepository
        carregarDados()
    }
    
    func carregarDados() {
        self.todosPagamentos = paymentRepository.fetchPagamentos()
        self.pacientes = patientRepository.fetchPacientes()
    }
    
    // MARK: - Lógica de Navegação de Tempo
    
    func avancarPeriodo() {
        let calendar = Calendar.current
        if viewMode == .mensal {
            currentDate = calendar.date(byAdding: .month, value: 1, to: currentDate) ?? currentDate
        } else {
            currentDate = calendar.date(byAdding: .year, value: 1, to: currentDate) ?? currentDate
        }
    }
    
    func voltarPeriodo() {
        let calendar = Calendar.current
        if viewMode == .mensal {
            currentDate = calendar.date(byAdding: .month, value: -1, to: currentDate) ?? currentDate
        } else {
            currentDate = calendar.date(byAdding: .year, value: -1, to: currentDate) ?? currentDate
        }
    }
    
    var labelPeriodo: String {
        let formatter = DateFormatter()
        if viewMode == .mensal {
            formatter.dateFormat = "MMMM yyyy"
        } else {
            formatter.dateFormat = "yyyy"
        }
        return formatter.string(from: currentDate).capitalized
    }
    
    // MARK: - Filtros e Cálculos Mágicos
    
    // String usada para comparar com o banco (ex: "2026/03" ou "2026")
    private var filtroReferencia: String {
        let formatter = DateFormatter()
        formatter.dateFormat = viewMode == .mensal ? "yyyy/MM" : "yyyy"
        return formatter.string(from: currentDate)
    }
    
    var pagamentosFiltrados: [MonthlyPayment] {
        return todosPagamentos.filter { $0.mesReferencia.hasPrefix(filtroReferencia) }
    }
    
    var pagamentosPendentes: [MonthlyPayment] {
        return pagamentosFiltrados.filter { !$0.pago }.sorted { $0.mesReferencia < $1.mesReferencia }
    }
    
    var pagamentosRealizados: [MonthlyPayment] {
        return pagamentosFiltrados.filter { $0.pago }.sorted { $0.mesReferencia > $1.mesReferencia }
    }
    
    var totalRecebidoText: String {
        let soma = pagamentosRealizados.reduce(0) { $0 + $1.valor }
        return String(format: "R$ %.0f", soma)
    }
    
    var totalPendenteText: String {
        let soma = pagamentosPendentes.reduce(0) { $0 + $1.valor }
        return String(format: "R$ %.0f", soma)
    }
    
    // MARK: - Funções Auxiliares para a View
    
    func paciente(for pagamento: MonthlyPayment) -> Patient? {
        return pacientes.first(where: { $0.id == pagamento.pacienteID })
    }
    
    func togglePagamento(pagamentoID: String) {
        if let index = todosPagamentos.firstIndex(where: { $0.id == pagamentoID }) {
            var pagamentoAtualizado = todosPagamentos[index]
            pagamentoAtualizado.pago.toggle()
            pagamentoAtualizado.dataPagamento = pagamentoAtualizado.pago ? Date() : nil
            
            // Salva no banco e recarrega
            paymentRepository.atualizarPagamento(pagamentoAtualizado)
            carregarDados()
        }
    }
    
    // Transforma "2026/03" em "Março/2026" para exibição bonita
    func formatarMesRefParaExibicao(_ ref: String) -> String {
        let partes = ref.split(separator: "/")
        guard partes.count == 2, let mesInt = Int(partes[1]) else { return ref }
        let meses = ["Jan", "Fev", "Mar", "Abr", "Mai", "Jun", "Jul", "Ago", "Set", "Out", "Nov", "Dez"]
        if mesInt >= 1 && mesInt <= 12 {
            return "\(meses[mesInt - 1])/\(partes[0])"
        }
        return ref
    }
}
