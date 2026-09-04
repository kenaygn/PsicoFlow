//
//  FakeSessionCard.swift
//  PsicoFlow
//
//  Created by Kenay on 15/07/26.
//

import SwiftUI

struct FakePaciente: Identifiable {
    let id = UUID()
    let nome: String
    let iniciais: String
    let hora: String
    let isNext: Bool
    let modalidade: String // "online" ou "presencial"
    let status: String // "agendada", "realizada", etc
    let tipo: String // "Fixa" ou "Avulsa"
}

let pacientesFila1 = [
    FakePaciente(nome: "Ana Carolina", iniciais: "AC", hora: "09:00", isNext: false, modalidade: "presencial", status: "Realizada", tipo: "Fixa"),
    FakePaciente(nome: "Marcos Silva", iniciais: "MS", hora: "10:00", isNext: true, modalidade: "online", status: "Agendada", tipo: "Fixa"),
    FakePaciente(nome: "Júlia Costa", iniciais: "JC", hora: "11:00", isNext: false, modalidade: "presencial", status: "Agendada", tipo: "Avulsa")
]

let pacientesFila2 = [
    FakePaciente(nome: "Roberto Alves", iniciais: "RA", hora: "14:00", isNext: false, modalidade: "online", status: "Agendada", tipo: "Fixa"),
    FakePaciente(nome: "Carla Mendes", iniciais: "CM", hora: "15:00", isNext: false, modalidade: "presencial", status: "Adiada", tipo: "Avulsa"),
    FakePaciente(nome: "Fernando Dias", iniciais: "FD", hora: "16:00", isNext: true, modalidade: "online", status: "Agendada", tipo: "Fixa")
]

struct FakeSessionCard: View {
    let paciente: FakePaciente
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                HStack(spacing: 6) {
                    Image(systemName: "clock")
                        .font(.system(size: 14))
                    Text(paciente.hora)
                        .font(.system(size: 16, weight: .semibold))
                }
                .foregroundColor(paciente.isNext ? .white : .primary)
                
                Spacer()
                
                if paciente.isNext {
                    Text("A SEGUIR")
                        .font(.system(size: 10, weight: .bold))
                        .padding(.horizontal, 8).padding(.vertical, 4)
                        .background(Color.teal).foregroundColor(.white)
                        .clipShape(Capsule())
                } else {
                    Text(paciente.status.uppercased())
                        .font(.system(size: 10, weight: .bold))
                        .padding(.horizontal, 8).padding(.vertical, 4)
                        .background(Color.gray.opacity(0.15))
                        .foregroundColor(.gray)
                        .clipShape(Capsule())
                }
            }
            
            // Info Paciente
            HStack(spacing: 12) {
                Circle()
                    .fill(paciente.isNext ? Color.white : Color.gray.opacity(0.1))
                    .frame(width: 40, height: 40)
                    .overlay(
                        Text(paciente.iniciais)
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(paciente.isNext ? .black : .primary)
                    )
                
                VStack(alignment: .leading, spacing: 6) {
                    Text(paciente.nome)
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundColor(paciente.isNext ? .white : .primary)
                    
                    HStack(spacing: 12) {
                        HStack(spacing: 4) {
                            Image(systemName: paciente.tipo == "Fixa" ? "repeat" : "1.circle")
                            Text(paciente.tipo)
                        }
                        .foregroundColor(paciente.tipo == "Fixa" ? Color(red: 0.89, green: 0.25, blue: 0.35) : .orange)
                        
                        HStack(spacing: 4) {
                            Image(systemName: paciente.modalidade == "online" ? "video" : "person.2")
                            Text(paciente.modalidade.capitalized)
                        }
                        .foregroundColor(paciente.isNext ? .gray : .secondary)
                    }
                    .font(.system(size: 13, weight: .medium))
                }
                Spacer()
            }
        }
        .padding(16)
        .overlay(alignment: .topTrailing) {
            if paciente.isNext {
                Circle().fill(.white.opacity(0.05)).frame(width: 130, height: 130).offset(x: 25, y: -40)
            }
        }
        .background(paciente.isNext ? Color(red: 15/255, green: 23/255, blue: 42/255) : Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .stroke(paciente.isNext ? Color.clear : Color.gray.opacity(0.1), lineWidth: 1)
        )
    }
}
