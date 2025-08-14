import Foundation

// Server Response
struct TempResponse: Codable {
    let isSuccess: Bool
    let code: Int
    let message: String
    let diaries: [Diary]

    private enum CodingKeys: String, CodingKey { case isSuccess, code, message, result }
    private enum ResultKeys: String, CodingKey { case diaries }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        isSuccess = try container.decode(Bool.self, forKey: .isSuccess)
        code      = try container.decode(Int.self,  forKey: .code)
        message   = try container.decode(String.self, forKey: .message)

        let result = try container.nestedContainer(keyedBy: ResultKeys.self, forKey: .result)
        diaries = try result.decode([Diary].self, forKey: .diaries)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(isSuccess, forKey: .isSuccess)
        try container.encode(code, forKey: .code)
        try container.encode(message, forKey: .message)

        var result = container.nestedContainer(keyedBy: ResultKeys.self, forKey: .result)
        try result.encode(diaries, forKey: .diaries)
    }
}







