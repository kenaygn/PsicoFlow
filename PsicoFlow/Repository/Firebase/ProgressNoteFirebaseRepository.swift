//
//  EvolutionFirebaseRepository.swift
//  PsicoFlow
//
//  Created by Kenay on 17/07/26.
//

import Foundation
import FirebaseFirestore

class ProgressNoteFirebaseRepository: ProgressNoteRepositoryProtocol {
    private let db = Firestore.firestore()
    
    private func collection(userId: String) -> CollectionReference {
        return db.collection("users").document(userId).collection("progressNotes")
    }
    
    func fetchProgressNotes(forPatientID patientID: String, userId: String) async throws -> [ProgressNote] {
        let snapshot = try await collection(userId: userId)
            .whereField("patientID", isEqualTo: patientID)
            .getDocuments()
        
        var notes = snapshot.documents.compactMap { try? $0.data(as: ProgressNote.self) }
        
        for i in 0..<notes.count {
            notes[i].content = EncryptionManager.shared.decrypt(base64String: notes[i].content, userId: userId)
        }
        
        return notes
    }
    
    func saveProgressNote(_ note: ProgressNote, userId: String) async throws {
        var secureNote = note
        
        secureNote.content = EncryptionManager.shared.encrypt(text: note.content, userId: userId)
        
        try collection(userId: userId).document(secureNote.id).setData(from: secureNote)
    }
    
    func updateProgressNote(_ note: ProgressNote, userId: String) async throws {
        var secureNote = note
        
        secureNote.content = EncryptionManager.shared.encrypt(text: note.content, userId: userId)
        
        try collection(userId: userId).document(secureNote.id).setData(from: secureNote, merge: true)
    }
    
    func deleteProgressNote(id: String, userId: String) async throws {
        try await collection(userId: userId).document(id).delete()
    }
}
