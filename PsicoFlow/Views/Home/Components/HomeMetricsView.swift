//
//  HomeMetricsView.swift
//  PsicoFlow
//
//  Created by Kenay on 24/08/26.
//

import SwiftUI

struct HomeMetricsView: View {
    @ObservedObject var viewModel: HomeViewModel
    
    var body: some View {
        HStack {
            QuickStatCard(
                title: "Sessões Hoje",
                value: viewModel.totalSessoesHojeText,
                icon: "calendar",
                style: .primary
            )
            
            Spacer()
            
            QuickStatCard(
                title: viewModel.valoresPendentesText == "R$ 0" ? "Tudo certo" : "A Receber",
                value: viewModel.valoresPendentesText,
                icon: viewModel.valoresPendentesText == "R$ 0" ? "sparkles" : "exclamationmark.circle",
                style: viewModel.valoresPendentesText == "R$ 0" ? .financeSuccess : .danger
            )
        }
    }
}
