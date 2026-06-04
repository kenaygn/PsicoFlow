//
//  TermsOfServiceView.swift
//  PsicoFlow
//
//  Created by Kenay on 04/06/26.
//

import SwiftUI

struct TermsOfServiceView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("Termos de Serviço")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    
                    Text("Última atualização: 04 de Junho de 2026")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .padding(.bottom, 8)
                
                // MARK: - Cláusulas
                //TODO: tem que mexer nelas tudo 
                Group {
                    TermSection(
                        title: "1. Aceitação dos Termos",
                        content: "Ao acessar e utilizar o aplicativo PsicoFlow, você concorda expressamente em cumprir estes Termos de Serviço. Este aplicativo é uma ferramenta destinada a profissionais de saúde para auxiliar no gerenciamento de suas rotinas clínicas e informações de pacientes."
                    )
                    
                    TermSection(
                        title: "2. Privacidade e LGPD",
                        content: "O tratamento de dados sensíveis e prontuários é realizado em estrita conformidade com a Lei Geral de Proteção de Dados (LGPD). Você, na figura de profissional de saúde, atua como o Controlador dos dados de seus pacientes, sendo responsável por inserir e gerenciar essas informações com o devido consentimento ético e legal."
                    )
                    
                    TermSection(
                        title: "3. Segurança e Acesso",
                        content: "Você é o único responsável por manter a confidencialidade das suas credenciais de acesso. Recomendamos fortemente a utilização dos recursos de segurança do dispositivo, como o Face ID, disponibilizados nas preferências do aplicativo, para evitar o acesso físico não autorizado aos dados da clínica."
                    )
                    
                    TermSection(
                        title: "4. Assinaturas e Pagamentos",
                        content: "O PsicoFlow pode oferecer funcionalidades Premium mediante assinatura. O faturamento, gerenciamento e cancelamento destas assinaturas são processados exclusivamente através da sua conta Apple, seguindo as políticas da App Store."
                    )
                    
                    TermSection(
                        title: "5. Limitação de Responsabilidade",
                        content: "O PsicoFlow atua como um sistema de apoio ao gerenciamento. Não nos responsabilizamos por perdas de dados decorrentes do mau uso do dispositivo ou por decisões clínicas tomadas com base nas anotações inseridas na plataforma."
                    )
                }
                
                Spacer(minLength: 40)
            }
            .padding(20)
        }
        .navigationTitle("Termos")
        .navigationBarTitleDisplayMode(.inline)
    }
}


#Preview {
    NavigationStack {
        TermsOfServiceView()
    }
}
