//
//  PatientFirebaseRepository.swift
//  PsicoFlow
//
//  Created by Kenay on 17/07/26.
//

import Foundation
import FirebaseFirestore

class PatientFirebaseRepository: PatientRepositoryProtocol {
    private let db = Firestore.firestore()
    
    private func patientsCollection(userId: String) -> CollectionReference {
        return db.collection("users").document(userId).collection("patients")
    }
    
    func fetchPatients(userId: String) async throws -> [Patient] {
        let snapshot = try await patientsCollection(userId: userId).getDocuments()
        var patients = snapshot.documents.compactMap { try? $0.data(as: Patient.self) }
        
        for i in 0..<patients.count {
            if let notes = patients[i].notes {
                patients[i].notes = EncryptionManager.shared.decrypt(base64String: notes, userId: userId)
            }
        }
        
        return patients
    }
    
    func savePatient(_ patient: Patient, userId: String) async throws {
        var securePatient = patient
        
        if let notes = securePatient.notes {
            securePatient.notes = EncryptionManager.shared.encrypt(text: notes, userId: userId)
        }
        
        try patientsCollection(userId: userId).document(securePatient.id).setData(from: securePatient)
    }
    
    func updatePatient(_ patient: Patient, userId: String) async throws {
        var securePatient = patient
        
        if let notes = securePatient.notes {
            securePatient.notes = EncryptionManager.shared.encrypt(text: notes, userId: userId)
        }
        
        try patientsCollection(userId: userId).document(securePatient.id).setData(from: securePatient, merge: true)
    }
    
    func deletePatientCascade(patientID: String, userId: String) async throws {
        let batch = db.batch()
        let userDocRef = db.collection("users").document(userId)
        
        let patientRef = userDocRef.collection("patients").document(patientID)
        batch.deleteDocument(patientRef)
        
        let sessions = try await userDocRef.collection("sessions")
            .whereField("patientID", isEqualTo: patientID).getDocuments()
        for doc in sessions.documents { batch.deleteDocument(doc.reference) }
        
        let payments = try await userDocRef.collection("payments")
            .whereField("patientID", isEqualTo: patientID).getDocuments()
        for doc in payments.documents { batch.deleteDocument(doc.reference) }
        
        let progressNotes = try await userDocRef.collection("progressNotes")
            .whereField("patientID", isEqualTo: patientID).getDocuments()
        for doc in progressNotes.documents { batch.deleteDocument(doc.reference) }
        
        let fixedSessions = try await userDocRef.collection("fixedSessions")
            .whereField("patientID", isEqualTo: patientID).getDocuments()
        for doc in fixedSessions.documents { batch.deleteDocument(doc.reference) }
        
        try await batch.commit()
    }
    
    func listenToPatients(userId: String, onChange: @escaping ([Patient]) -> Void) -> ListenerRegistration {
        return patientsCollection(userId: userId).addSnapshotListener { snapshot, error in
            guard let documents = snapshot?.documents else {
                print("Error listening to patients: \(error?.localizedDescription ?? "Unknown")")
                return
            }
            
            var patients = documents.compactMap { try? $0.data(as: Patient.self) }
            
            for i in 0..<patients.count {
                if let notes = patients[i].notes {
                    patients[i].notes = EncryptionManager.shared.decrypt(base64String: notes, userId: userId)
                }
            }
            
            onChange(patients)
        }
    }
    
    func blockExcessPatients(userId: String) async throws {
        let db = Firestore.firestore()
        let patientsRef = db.collection("users").document(userId).collection("patients")
        
        let snapshot = try await patientsRef.whereField("status", isEqualTo: PatientStatus.active.rawValue).getDocuments()
        
        var activePatients = snapshot.documents.compactMap { try? $0.data(as: Patient.self) }
        
        if activePatients.count <= 5 { return }
        
        activePatients.sort { $0.createdAt < $1.createdAt }
        let patientsToBlock = Array(activePatients[5...])
        
        let batch = db.batch()
        
        for patient in patientsToBlock {
            let docRef = patientsRef.document(patient.id)
            batch.updateData([
                "status": PatientStatus.inactive.rawValue,
                "blockedBySystem": true
            ], forDocument: docRef)
        }
        
        try await batch.commit()
        print("Block completed: \(patientsToBlock.count) patients were deactivated by the system.")
    }
    
    func unblockPatients(userId: String) async throws {
        let db = Firestore.firestore()
        let patientsRef = db.collection("users").document(userId).collection("patients")
        
        let snapshot = try await patientsRef.whereField("blockedBySystem", isEqualTo: true).getDocuments()
        
        if snapshot.documents.isEmpty { return }
        
        let batch = db.batch()
        
        for document in snapshot.documents {
            batch.updateData([
                "status": PatientStatus.active.rawValue,
                "blockedBySystem": false
            ], forDocument: document.reference)
        }
        
        try await batch.commit()
        print("Unblock completed: \(snapshot.documents.count) patients were reactivated.")
    }
}
