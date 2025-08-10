import Foundation

// Server Response
struct TempResponse: Decodable {
    // 최상위 응답 메타데이터
    let isSuccess: Bool
    let code: Int
    let message: String

    // result 내부의 diaries만 꺼냄
    let diaries: [Diary]

    // CodingKeys: 최상위 키와 매핑
    private enum CodingKeys: String, CodingKey {
        case isSuccess, code, message, result
    }
    // ResultKeys: "result" 내부
    private enum ResultKeys: String, CodingKey {
        case diaries
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        // 1) 메타데이터
        isSuccess = try container.decode(Bool.self,   forKey: .isSuccess)
        code      = try container.decode(Int.self,    forKey: .code)
        message   = try container.decode(String.self, forKey: .message)

        // 2) result 내부
        let resultContainer = try container.nestedContainer(
            keyedBy: ResultKeys.self,
            forKey: .result
        )
        // 3) diaries만 디코딩
        diaries = try resultContainer.decode([Diary].self, forKey: .diaries)
    }
}






