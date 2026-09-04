//
//  EvolutionRepositoryProtocol.swift
//  PsicoFlow
//
//  Created by Kenay on 06/04/26.
//

import Foundation

protocol ProgressNoteRepositoryProtocol {
    func fetchProgressNotes(forPatientID patientID: String, userId: String) async throws -> [ProgressNote]
    func saveProgressNote(_ note: ProgressNote, userId: String) async throws
    func updateProgressNote(_ note: ProgressNote, userId: String) async throws
    func deleteProgressNote(id: String, userId: String) async throws
}
