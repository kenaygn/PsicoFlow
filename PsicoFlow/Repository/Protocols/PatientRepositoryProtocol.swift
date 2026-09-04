//
//  PatientRepositoryProtocol.swift
//  PsicoFlow
//
//  Created by Kenay on 06/04/26.
//

import Foundation

protocol PatientRepositoryProtocol {
    func fetchPatients(userId: String) async throws -> [Patient]
    func savePatient(_ patient: Patient, userId: String) async throws
    func updatePatient(_ patient: Patient, userId: String) async throws
    func deletePatientCascade(patientID: String, userId: String) async throws
}
