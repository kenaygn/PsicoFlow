//
//  UnderlinedTimePicker.swift
//  PsicoFlow
//
//  Created by Kenay on 15/07/26.
//

import SwiftUI

struct UnderlinedTimePicker: View {
    let titulo: String
    @Binding var selecao: String
    let opcoes: [String]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(titulo)
                .font(.footnote).bold()
                .foregroundColor(.secondary)
            
            Menu {
                Picker(titulo, selection: $selecao) {
                    ForEach(opcoes, id: \.self) { horario in
                        Text(horario).tag(horario)
                    }
                }
            } label: {
                HStack {
                    Text(selecao)
                        .font(.title3)
                        .foregroundColor(.primary)
                    
                    Spacer()
                    
                    Image(systemName: "chevron.up.chevron.down")
                        .font(.caption)
                        .foregroundColor(.teal)
                }
            }
            
            Rectangle()
                .frame(height: 1)
                .foregroundColor(Color(.systemGray3))
        }
    }
}
