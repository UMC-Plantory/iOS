//
//  APIManager.swift
//  Plantory
//
//  Created by 주민영 on 7/2/25.
//

import Foundation
import Moya
import Alamofire

class APIManager: @unchecked Sendable {
    static let shared = APIManager()
    
    private let session: Session
    private let loggerPlugin: PluginType
    
    private init() {
        session = Session()
        loggerPlugin = NetworkLoggerPlugin(configuration: .init(logOptions: .verbose))
    }
    
    /// 실제 API 요청용 MoyaProvider
    public func createProvider<T: TargetType>(for targetType: T.Type) -> MoyaProvider<T> {
        return MoyaProvider<T>(
            session: session,
            plugins: [loggerPlugin]
        )
    }
    
    /// 이미지 요청 시 MoyaProvidder
    func createImageProvider<T: TargetType>(for targetType: T.Type) -> MoyaProvider<T> {
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 300
        config.timeoutIntervalForResource = 300

        let session = Session(configuration: config)
        return MoyaProvider<T>(
            session: session,
            plugins: [loggerPlugin]
        )
    }
    
    /// 테스트용 MoyaProvider
    public func testProvider<T: TargetType>(for targetType: T.Type) -> MoyaProvider<T> {
        return MoyaProvider<T>(
            stubClosure: MoyaProvider.immediatelyStub,
            plugins: [loggerPlugin]
        )
    }
}
