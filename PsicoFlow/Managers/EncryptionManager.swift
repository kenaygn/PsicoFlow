//
//  EncryptionManager.swift
//  PsicoFlow
//
//  Created by Kenay on 24/08/26.
//

import Foundation
import CryptoKit

class EncryptionManager {
    static let shared = EncryptionManager()
    
    private let salt = "Psyes_Secure_Salt_2026_!@#".data(using: .utf8)!
    
    private init() {}
    
    private func getSymmetricKey(for userId: String) -> SymmetricKey {
        let inputKeyMaterial = SymmetricKey(data: userId.data(using: .utf8)!)
        
        return HKDF<SHA256>.deriveKey(
            inputKeyMaterial: inputKeyMaterial,
            salt: salt,
            info: Data(),
            outputByteCount: 32
        )
    }
    
    func encrypt(text: String, userId: String) -> String {
        guard !text.trimmingCharacters(in: .whitespaces).isEmpty else { return text }
        
        let key = getSymmetricKey(for: userId)
        guard let data = text.data(using: .utf8) else { return text }
        
        do {
            let sealedBox = try AES.GCM.seal(data, using: key)
            return sealedBox.combined?.base64EncodedString() ?? text
        } catch {
            print("Erro ao criptografar: \(error.localizedDescription)")
            return text
        }
    }
    
    func decrypt(base64String: String, userId: String) -> String {
        guard !base64String.trimmingCharacters(in: .whitespaces).isEmpty else { return base64String }
        
        let key = getSymmetricKey(for: userId)
        
        guard let data = Data(base64Encoded: base64String) else {
            return base64String
        }
        
        do {
            let sealedBox = try AES.GCM.SealedBox(combined: data)
            let decryptedData = try AES.GCM.open(sealedBox, using: key)
            return String(data: decryptedData, encoding: .utf8) ?? base64String
        } catch {
            return base64String
        }
    }
}
