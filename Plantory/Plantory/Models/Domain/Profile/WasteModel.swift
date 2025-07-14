import Foundation

// Server Response for 휴지통 목록
struct WasteResponse: Decodable {
    /// 성공 여부
    let isSuccess: Bool
    /// HTTP 상태 코드
    let code: Int
    /// 응답 메시지
    let message: String
    /// 일기 리스트
    let diaries: [Diary]

    // 최상위 키 매핑
    private enum CodingKeys: String, CodingKey {
        case isSuccess, code, message, result
    }
    // result 내부 키 매핑
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
}
