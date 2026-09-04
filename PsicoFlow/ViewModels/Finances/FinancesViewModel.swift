//
//  FinancesViewModel.swift
//  PsicoFlow
//
//  Created by Kenay on 07/04/26.
//

import Foundation
import Combine
import SwiftUI // Necessário para usar o withAnimation na ViewModel
import FirebaseFirestore // Necessário para segurar o ListenerRegistration

/// Define os períodos de agregação disponíveis para a visualização financeira.
enum FinanceViewMode {
    case mensal
    case anual
}

/// ViewModel responsável pelo processamento do fluxo de caixa (recebimentos e pendências).
@MainActor
class FinanceViewModel: ObservableObject {
    
    @Published private var todosPagamentos: [MonthlyPayment] = []
    @Published private var pacientes: [Patient] = []
    
    @Published var viewMode: FinanceViewMode = .mensal
    @Published var currentDate: Date = Date()
    
    private let financeAnalyzer = FinanceAnalyzerService()
    
    private let paymentRepository: PaymentRepositoryProtocol
    private let patientRepository: PatientRepositoryProtocol
    
    // Listener para manter a conexão em tempo real aberta
    private var pagamentosListener: ListenerRegistration?
    
    init(
        paymentRepository: PaymentRepositoryProtocol = PaymentFirebaseRepository(),
        patientRepository: PatientRepositoryProtocol = PatientFirebaseRepository()
    ) {
        self.paymentRepository = paymentRepository
        self.patientRepository = patientRepository
    }
    
    // MARK: - Limpeza de Memória (MUITO IMPORTANTE)
    deinit {
        pagamentosListener?.remove()
    }
    
    // MARK: - Carregamento Offline-First
    /// Sincroniza o estado local com a base de dados em tempo real.
    func carregarDados(userId: String) {
        guard !userId.isEmpty else { return }
        
        // Remove listener antigo para evitar duplicatas se a tela for recarregada
        pagamentosListener?.remove()
        
        // Inicia a escuta em tempo real (Retorna o cache instantaneamente)
        // Se a sua PaymentRepositoryProtocol reclamar, adicione a assinatura da função lá!
        if let firebaseRepo = paymentRepository as? PaymentFirebaseRepository {
            pagamentosListener = firebaseRepo.escutarPagamentos(userId: userId) { [weak self] novosPagamentos in
                guard let self = self else { return }
                
                // Anima as mudanças vindo da rede ou do cache
                withAnimation(.easeInOut(duration: 0.5)) {
                    self.todosPagamentos = novosPagamentos
                }
            }
        }
        
        // Busca de pacientes (pode se tornar listener futuramente se desejar)
        Task {
            do {
                let fetchedPacientes = try await patientRepository.fetchPatients(userId: userId)
                withAnimation {
                    self.pacientes = fetchedPacientes
                }
            } catch {
                print("Erro ao carregar pacientes: \(error.localizedDescription)")
            }
        }
    }
    
    // MARK: - Ações e Mutação
    /// Alterna o status de quitação de uma mensalidade e persiste a alteração de imediato.
    func togglePagamento(pagamentoID: String, userId: String) {
        if let index = todosPagamentos.firstIndex(where: { $0.id == pagamentoID }) {
            
            // 1. ATUALIZAÇÃO OTIMISTA: Muda a interface antes de ir para a internet
            var pagamentoAtualizado = todosPagamentos[index]
            pagamentoAtualizado.paid.toggle()
            pagamentoAtualizado.paymentDate = pagamentoAtualizado.paid ? Date() : nil
            
            withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                self.todosPagamentos[index] = pagamentoAtualizado
            }
            
            // 2. SALVAMENTO EM BACKGROUND: Deixa o Firebase sincronizar silenciosamente
            Task {
                do {
                    try await paymentRepository.updatePayment(pagamentoAtualizado, userId: userId)
                } catch {
                    print("Erro ao atualizar pagamento: \(error.localizedDescription)")
                    // Em caso de falha crítica (ex: permissão negada), você poderia reverter a UI aqui
                }
            }
        }
    }
    
    // MARK: - Propriedades Computadas (Inalteradas)
    var dataDaPrimeiraPendenciaAtrasada: Date? {
        return financeAnalyzer.identificarPrimeiroMesComAtraso(nos: todosPagamentos)
    }
    
    var labelPrimeiraPendencia: String {
        guard let data = dataDaPrimeiraPendenciaAtrasada else { return "" }
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "pt_BR")
        formatter.dateFormat = "MMMM/yyyy"
        return formatter.string(from: data).capitalized
    }
    
    func avancarPeriodo() {
        let calendar = Calendar.current
        let component: Calendar.Component = viewMode == .mensal ? .month : .year
        currentDate = calendar.date(byAdding: component, value: 1, to: currentDate) ?? currentDate
    }
    
    func voltarPeriodo() {
        let calendar = Calendar.current
        let component: Calendar.Component = viewMode == .mensal ? .month : .year
        currentDate = calendar.date(byAdding: component, value: -1, to: currentDate) ?? currentDate
    }
    
    var labelPeriodo: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "pt_BR")
        formatter.dateFormat = viewMode == .mensal ? "MMMM yyyy" : "yyyy"
        return formatter.string(from: currentDate).capitalized
    }
    
    func irParaPeriodoAtual() {
        currentDate = Date()
    }
    
    var isPeriodoAtual: Bool {
        let calendar = Calendar.current
        let hoje = Date()
        
        if viewMode == .mensal {
            return calendar.isDate(currentDate, equalTo: hoje, toGranularity: .month)
        } else {
            return calendar.isDate(currentDate, equalTo: hoje, toGranularity: .year)
        }
    }
    
    private var filtroReferencia: String {
        let formatter = DateFormatter()
        formatter.dateFormat = viewMode == .mensal ? "yyyy/MM" : "yyyy"
        return formatter.string(from: currentDate)
    }
    
    var pagamentosFiltrados: [MonthlyPayment] {
        return todosPagamentos.filter { $0.referenceMonth.hasPrefix(filtroReferencia) }
    }
    
    var pagamentosPendentes: [MonthlyPayment] {
        return pagamentosFiltrados
            .filter { !$0.paid }
            .sorted { $0.referenceMonth < $1.referenceMonth }
    }
    
    var pagamentosRealizados: [MonthlyPayment] {
        return pagamentosFiltrados
            .filter { $0.paid }
            .sorted { $0.referenceMonth > $1.referenceMonth }
    }
    
    var totalRecebidoText: String {
        let soma = pagamentosRealizados.reduce(0) { $0 + $1.value }
        return String(format: "R$ %.0f", soma)
    }
    
    var totalPendenteText: String {
        let soma = pagamentosPendentes.reduce(0) { $0 + $1.value }
        return String(format: "R$ %.0f", soma)
    }
    
    func paciente(for pagamento: MonthlyPayment) -> Patient? {
        return pacientes.first(where: { $0.id == pagamento.patientID })
    }
    
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
