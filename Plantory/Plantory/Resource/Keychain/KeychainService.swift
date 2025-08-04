//
//  KeychainService.swift
//  Plantory
//
//  Created by 주민영 on 7/24/25.
//

import Foundation
import Security

class KeychainService {
    static let shared = KeychainService()
    
    private init() {}
    
    private let account = "authToken"
    private let service = "com.plantory.Plantory"
    
    @discardableResult
    private func saveTokenInfo(_ tokenInfo: TokenInfo) -> OSStatus {
        do {
            let data = try JSONEncoder().encode(tokenInfo)
            
            let query: [String: Any] = [
                kSecClass as String: kSecClassGenericPassword,
                kSecAttrAccount as String: account,
                kSecAttrService as String: service,
                kSecValueData as String: data,
                kSecAttrAccessible as String: kSecAttrAccessibleAfterFirstUnlock
            ]
            
            SecItemDelete(query as CFDictionary)
            
            return SecItemAdd(query as CFDictionary, nil)
        } catch {
            print("JSON 인코딩 실패:", error)
            return errSecParam
        }
    }
    
    private func loadTokenInfo() -> TokenInfo? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: account,
            kSecAttrService as String: service,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        
        var item: CFTypeRef?
        let status = SecItemCopyMatching(query as CFDictionary, &item)
        
        guard status == errSecSuccess,
              let data = item as? Data else {
            print("토큰 정보 불러오기 실패 - status:", status)
            return nil
        }
        
        do {
            return try JSONDecoder().decode(TokenInfo.self, from: data)
        } catch {
            print("❌ JSON 디코딩 실패:", error)
            return nil
        }
    }
    
    @discardableResult
    private func deleteTokenInfo() -> OSStatus {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: account,
            kSecAttrService as String: service
        ]
        
        return SecItemDelete(query as CFDictionary)
    }
    
    public func saveToken(_ tokenInfo: TokenInfo) {
        let saveStatus = self.saveTokenInfo(tokenInfo)
        print("토큰이 저장됨, \(saveStatus == errSecSuccess)")
    }
    
    public func loadToken() -> TokenInfo? {
        if let loadedToken = self.loadTokenInfo() {
            print("accessToken:", loadedToken.accessToken)
            print("RefreshToken:", loadedToken.refreshToken)
            return loadedToken
        } else {
            print("토큰 정보 없음")
            return nil
        }
    }
    
    public func deleteToken() -> OSStatus {
        let deleteStatus = self.deleteTokenInfo()
        print(deleteStatus == errSecSuccess ? "삭제 성공" : "삭제 실패")
        return deleteStatus
    }
}
