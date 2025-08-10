//
//  Config.swift
//  Plantory
//
//  Created by 주민영 on 7/24/25.
//

import Foundation

enum Config {
    private static let infoDictionary: [String: Any] = {
        guard let dict = Bundle.main.infoDictionary else {
            fatalError("Plist 없음")
        }
        return dict
    }()
    
    static let baseUrl: String = {
        guard let baseUrl = Config.infoDictionary["BASE_URL"] as? String else {
            fatalError()
        }
        return baseUrl
    }()
    
    static let kakaoKey: String = {
        guard let kakaoKey = Config.infoDictionary["KAKAO_KEY"] as? String else {
            fatalError()
        }
        return kakaoKey
    }()
}
