//
//  PrivacyPolicyView.swift
//  PsicoFlow
//
//  Created by Kenay on 04/06/26.
//

import SwiftUI

struct PrivacyPolicyView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("Política de Privacidade")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    
                    Text("Última atualização: 04 de Junho de 2026")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .padding(.bottom, 8)
                
                // MARK: - Cláusulas de Privacidade
                //TODO: tem que mexer nelas tudo 
                Group {
                    PrivacySection(
                        title: "1. Coleta de Dados",
                        content: "O Psyes coleta apenas as informações estritamente necessárias para o funcionamento do sistema de gestão clínica. Isso inclui seus dados de cadastro profissional e as informações que você insere ativamente sobre seus pacientes, sessões e evoluções."
                    )
                    
                    PrivacySection(
                        title: "2. Uso das Informações",
                        content: "Os dados inseridos no aplicativo são utilizados exclusivamente para facilitar a sua organização profissional. O Psyes não acessa, não analisa e não utiliza os prontuários ou dados financeiros dos seus pacientes para nenhum fim analítico ou publicitário."
                    )
                    
                    PrivacySection(
                        title: "3. Armazenamento e Segurança",
                        content: "Nós adotamos padrões elevados de segurança e criptografia para proteger as informações armazenadas. Encorajamos o uso das ferramentas nativas do seu dispositivo, como o Face ID ou Touch ID, para adicionar uma camada extra de proteção física ao aplicativo."
                    )
                    
                    PrivacySection(
                        title: "4. Compartilhamento de Dados",
                        content: "Garantimos o sigilo profissional. Sob nenhuma circunstância nós vendemos, alugamos ou compartilhamos seus dados pessoais ou os dados dos seus pacientes com terceiros, exceto quando estritamente exigido por determinação legal ou judicial."
                    )
                    
                    PrivacySection(
                        title: "5. Seus Direitos (LGPD)",
                        content: "Em conformidade com a Lei Geral de Proteção de Dados, você tem o direito de acessar, corrigir, exportar ou solicitar a exclusão permanente de todos os seus dados e de seus pacientes dos nossos servidores a qualquer momento, através das configurações do seu perfil."
                    )
                }
                
                Spacer(minLength: 40)
            }
            .padding(20)
        }
        .navigationTitle("Privacidade")
        .navigationBarTitleDisplayMode(.inline)
    }
}



#Preview {
    NavigationStack {
        PrivacyPolicyView()
    }
}
