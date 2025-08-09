//
//  TokenKeychain.swift
//  Plantory
//
//  Created by 주민영 on 7/24/25.
//

import Foundation

protocol TokenProviding {
    var accessToken: String? { get set }
    func refreshToken(completion: @escaping (String?, Error?) -> Void)
}

struct TokenInfo: Codable {
    var accessToken: String
    var refreshToken: String
}
