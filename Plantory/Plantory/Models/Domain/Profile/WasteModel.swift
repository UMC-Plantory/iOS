import Foundation

// Server Response for 휴지통 목록
struct WasteResponse: Codable {
    let isSuccess: Bool
    let code: Int
    let message: String
    let diaries: [Diary]

    private enum CodingKeys: String, CodingKey {
        case isSuccess, code, message, result
    }
    private enum ResultKeys: String, CodingKey {
        case diaries
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        isSuccess = try container.decode(Bool.self, forKey: .isSuccess)
        code      = try container.decode(Int.self, forKey: .code)
        message   = try container.decode(String.self, forKey: .message)

        let resultContainer = try container.nestedContainer(
            keyedBy: ResultKeys.self,
            forKey: .result
        )
        diaries = try resultContainer.decode([Diary].self, forKey: .diaries)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(isSuccess, forKey: .isSuccess)
        try container.encode(code, forKey: .code)
        try container.encode(message, forKey: .message)

        var resultContainer = container.nestedContainer(keyedBy: ResultKeys.self, forKey: .result)
        try resultContainer.encode(diaries, forKey: .diaries)
    }
}



/// 휴지통으로 보내기!!!!! 응답 모델
public struct WastePatchResponse: Codable {}

/// 휴지통 일기 영구!! 삭제 응답 모델
public struct WasteDeleteResponse: Codable {
    /// 요청 성공 여부
    public let isSuccess: Bool
    /// HTTP 상태 코드
    public let code: Int
    /// 응답 메시지
    public let message: String
}
