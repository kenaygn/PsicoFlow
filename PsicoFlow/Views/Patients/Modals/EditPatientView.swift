import SwiftUI

struct EditPatientView: View {
    @Environment(\.dismiss) var dismiss
    
    // Recebe o paciente original como Binding para alterar direto na tela anterior
    @Binding var pacienteAtual: Patient
    
    // A nossa ViewModel reaproveitada
    @StateObject private var viewModel: PatientFormViewModel
    
    // Injetamos o paciente na ViewModel assim que a tela abre
    init(pacienteAtual: Binding<Patient>) {
        self._pacienteAtual = pacienteAtual
        // Instancia a ViewModel já passando o paciente que precisa ser editado
        self._viewModel = StateObject(wrappedValue: PatientFormViewModel(paciente: pacienteAtual.wrappedValue))
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Informações Pessoais")) {
                    TextField("Nome completo", text: $viewModel.nome)
                        .textInputAutocapitalization(.words)
                    
                    TextField("E-mail", text: $viewModel.email)
                        .keyboardType(.emailAddress)
                        .autocorrectionDisabled()
                        .textInputAutocapitalization(.never)
                    
                    TextField("Telefone (WhatsApp)", text: $viewModel.telefone)
                        .keyboardType(.phonePad)
                    
                    TextField("Contato de Emergência (Opcional)", text: $viewModel.contatoEmergencia)
                        .keyboardType(.phonePad)
                }
                
                Section(header: Text("Sessão e Contrato")) {
                    Picker("Status do Paciente", selection: $viewModel.status) {
                        ForEach(PatientStatus.allCases, id: \.self) { statusItem in
                            Text(statusItem.rawValue).tag(statusItem)
                        }
                    }
                    
                    HStack {
                        Text("R$").foregroundColor(.secondary)
                        TextField("Valor Mensal (Ex: 150,00)", text: $viewModel.valorTexto)
                            .keyboardType(.decimalPad)
                    }
                }
                
                Section(header: Text("Observações Iniciais"), footer: Text("Informações de triagem ou diagnóstico inicial.")) {
                    TextEditor(text: $viewModel.observacoes)
                        .frame(minHeight: 80)
                }
            }
            .navigationTitle("Editar Paciente")
            .navigationBarTitleDisplayMode(.inline)
            
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancelar") { dismiss() }
                        .foregroundColor(.red)
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Salvar") {
                        // A ViewModel entrega o paciente pronto e mastigado, e a View apenas atualiza o Binding
                        pacienteAtual = viewModel.obterPacienteAtualizado()
                        dismiss()
                    }
                    .fontWeight(.bold)
                    .foregroundColor(viewModel.isFormValid ? .teal : .gray)
                    .disabled(!viewModel.isFormValid)
                }
            }
        }
    }
}
