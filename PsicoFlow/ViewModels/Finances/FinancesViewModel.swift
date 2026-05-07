//
//  FinancesViewModel.swift
//  PsicoFlow
//
//  Created by Kenay on 07/04/26.
//

import Foundation
import Combine

/// Define os períodos de agregação disponíveis para a visualização financeira.
enum FinanceViewMode {
    case mensal
    case anual
}

/// ViewModel responsável pelo processamento do fluxo de caixa (recebimentos e pendências).
/// Gerencia a navegação temporal e a filtragem de pagamentos cruzando dados com o repositório de pacientes.
class FinanceViewModel: ObservableObject {
        
    @Published private var todosPagamentos: [MonthlyPayment] = []
    @Published private var pacientes: [Patient] = []
    
    @Published var viewMode: FinanceViewMode = .mensal
    @Published var currentDate: Date = Date()
        
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
        
    /// Sincroniza o estado local com a base de dados principal.
    func carregarDados() {
        self.todosPagamentos = paymentRepository.fetchPagamentos()
        self.pacientes = patientRepository.fetchPacientes()
    }
        
    /// Avança o calendário em 1 mês ou 1 ano, dependendo do modo de visualização atual.
    func avancarPeriodo() {
        let calendar = Calendar.current
        let component: Calendar.Component = viewMode == .mensal ? .month : .year
        currentDate = calendar.date(byAdding: component, value: 1, to: currentDate) ?? currentDate
    }
    
    /// Retrocede o calendário em 1 mês ou 1 ano, dependendo do modo de visualização atual.
    func voltarPeriodo() {
        let calendar = Calendar.current
        let component: Calendar.Component = viewMode == .mensal ? .month : .year
        currentDate = calendar.date(byAdding: component, value: -1, to: currentDate) ?? currentDate
    }
    
    /// Retorna a string formatada do período selecionado para exibição no cabeçalho (Ex: "Abril 2026" ou "2026").
    var labelPeriodo: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "pt_BR")
        formatter.dateFormat = viewMode == .mensal ? "MMMM yyyy" : "yyyy"
        
        return formatter.string(from: currentDate).capitalized
    }
        
    /// Chave de filtragem baseada na ISO string adaptada para comparação rápida (ex: "2026/04").
    private var filtroReferencia: String {
        let formatter = DateFormatter()
        formatter.dateFormat = viewMode == .mensal ? "yyyy/MM" : "yyyy"
        return formatter.string(from: currentDate)
    }
    
    var pagamentosFiltrados: [MonthlyPayment] {
        return todosPagamentos.filter { $0.mesReferencia.hasPrefix(filtroReferencia) }
    }
    
    var pagamentosPendentes: [MonthlyPayment] {
        return pagamentosFiltrados
            .filter { !$0.pago }
            .sorted { $0.mesReferencia < $1.mesReferencia }
    }
    
    var pagamentosRealizados: [MonthlyPayment] {
        return pagamentosFiltrados
            .filter { $0.pago }
            .sorted { $0.mesReferencia > $1.mesReferencia }
    }
    
    var totalRecebidoText: String {
        let soma = pagamentosRealizados.reduce(0) { $0 + $1.valor }
        return String(format: "R$ %.0f", soma)
    }
    
    var totalPendenteText: String {
        let soma = pagamentosPendentes.reduce(0) { $0 + $1.valor }
        return String(format: "R$ %.0f", soma)
    }
        
    /// Retorna os dados do paciente associado a uma cobrança específica.
    func paciente(for pagamento: MonthlyPayment) -> Patient? {
        return pacientes.first(where: { $0.id == pagamento.pacienteID })
    }
    
    /// Alterna o status de quitação de uma mensalidade e persiste a alteração de imediato.
    func togglePagamento(pagamentoID: String) {
        if let index = todosPagamentos.firstIndex(where: { $0.id == pagamentoID }) {
            var pagamentoAtualizado = todosPagamentos[index]
            pagamentoAtualizado.pago.toggle()
            pagamentoAtualizado.dataPagamento = pagamentoAtualizado.pago ? Date() : nil
            
            paymentRepository.atualizarPagamento(pagamentoAtualizado)
            carregarDados()
        }
    }
    
    /// Converte a chave referencial de banco de dados (ex: "2026/03") em um formato amigável para a View (ex: "Mar/2026").
    func formatarMesRefParaExibicao(_ ref: String) -> String {
        // Note: Para maior robustez em escalabilidade internacional e localização de sistema,
        // considere converter o prefixo numérico em uma Date real e formatá-la via DateFormatter,
        // ao invés de usar um array estático de strings (Hardcoded Array).
        let partes = ref.split(separator: "/")
        guard partes.count == 2, let mesInt = Int(partes[1]) else { return ref }
        
        let meses = ["Jan", "Fev", "Mar", "Abr", "Mai", "Jun", "Jul", "Ago", "Set", "Out", "Nov", "Dez"]
        
        if mesInt >= 1 && mesInt <= 12 {
            return "\(meses[mesInt - 1])/\(partes[0])"
        }
        return ref
    }
}
