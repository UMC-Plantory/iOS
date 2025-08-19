//
//  DiaryAPI.swift
//  Plantory
//
//  Created by 박병선 on 8/2/25.
//
import Foundation
import Moya
import Alamofire

enum DiarySort: String, Codable { case oldest, latest }

enum DiaryRouter : APITargetType {
    case fetchFilteredDiaries(filterData: DiaryFilterRequest)
    case fetchDiary(id: Int) //단일 일기 데이터 조회
    case editDiary(id: Int, data: DiaryEditRequest)//일기 수정
    case moveToTrash(ids: [Int])//일기 휴지통 이동
    case deletePermanently(ids: [Int])//일기 영구 삭제
    case searchDiary(DiarySearchRequest)//일기 검색(호출O)
    case scrapOn(id: Int) //스크랩
    case scrapOff(id: Int) //스크랩 취소
    case tempStatus(ids: [Int]) //일기 임시보관/복원(토글)
}

extension DiaryRouter {
    var baseURL: URL {
        return URL(string: "\(Config.baseUrl)")!
    }

    var path: String {
        switch self {
        case .fetchFilteredDiaries:
            return "/diaries/filter"
        case .fetchDiary(let id):
            return "/diaries/\(id)"
        case .editDiary(let id, _):
            return "/diaries/\(id)"
        case .moveToTrash: //일기 휴지통 이동
            return "/diaries/waste-status"
        case .deletePermanently
            :return "/diaries"
        case .searchDiary:
            return "/diaries/search"
        case .scrapOn(let id):
            return "/diaries/\(id)/scrap-status/on"
        case .scrapOff(let id):
            return "/diaries/\(id)/scrap-status/off"
        case .tempStatus:
            return "/diaries/temp-status"
        }
    }

    var method: Moya.Method {
        switch self {
        case .fetchFilteredDiaries:
            return .get
        case .fetchDiary:// 단일 일기 조회(request 없음)
            return .get
        case .editDiary:
            return .patch
        case .moveToTrash: //일기 휴지통 이동
            return .patch
        case .deletePermanently://영구 삭제
            return .delete
        case .searchDiary:
            return .get
        case .scrapOn:
            return .patch
        case .scrapOff:
            return .patch
        case .tempStatus:
            return .patch
        }
    }

    var task: Task {
        switch self {
        case .fetchFilteredDiaries(let filterData):
            return .requestParameters(parameters: filterData.toParameters(),
                encoding: URLEncoding.queryString
            )
        case .fetchDiary:
            return .requestPlain
        case .editDiary(_, let body)
            :return .requestJSONEncodable(body)
        case .searchDiary(let req):
            return .requestParameters(parameters: req.toParameters(), encoding: URLEncoding.queryString)
        case .moveToTrash(let ids):
            let body: [String: Any] = ["diaryIds": ids]
            return .requestParameters(parameters: body, encoding: JSONEncoding.default)
        case .deletePermanently(let ids):
                    let body = DeleteRequest(diaryIds: ids)
                    return .requestJSONEncodable(body)   // DELETE with body
        case .tempStatus(let ids):
                   return .requestJSONEncodable(TempStatusRequest(diaryIds: ids))
        case .scrapOn, .scrapOff:
            return .requestPlain
        }
    }
    
    var headers: [String: String]? {
        ["Content-Type": "application/json"]
    }
    
    var sampleData: Data {
            switch self {
            case .fetchFilteredDiaries:
                // 필터링된 일기 리스트
                return """
                {
                      "isSuccess": true,
                      "code": "COMMON200",
                      "message": "성공입니다.",
                      "result": {
                        "diaries": [
                          {
                            "diaryId": 1,
                            "diaryDate": "2025-06-20",
                            "title": "일기 제목 1",
                            "status": "NORMAL",
                            "emotion": "HAPPY",
                            "content": "일기 내용"
                          },
                          {
                            "diaryId": 2,
                            "diaryDate": "2025-06-21",
                            "title": "일기 제목 2",
                            "status": "SCRAP",
                            "emotion": "SAD",
                            "content": "일기 내용"
                          }
                        ],
                        "hasNext": true,
                        "nextCursor": "2025-06-21"
                      }
                    }
                """.data(using: .utf8)!

            case .fetchDiary(let id):
                // 단일 일기 조회
                return """
                {
                  "isSuccess": true,
                  "code": "COMMON200",
                  "message": "성공입니다.",
                  "result": {
                    "diaryId": 1,
                    "diaryDate": "2025-06-20"
                    "emotion": "HAPPY",
                    "title": "일기 제목1",
                    "content": "오늘은…",
                    "diaryImgUrl": "https…",
                    "status": "NORMAL"
                  }
                }
                """.data(using: .utf8)!

            case .editDiary(let id, _):
                // 수정된 일기 응답
                return """
                {
                  "isSuccess": true,
                  "code": "COMMON200",
                  "message": "일기 수정 성공",
                  "result": {
                    "diaryId": 1,
                    "diaryDate": "2025-06-20"
                    "emotion": "HAPPY",
                    "title": "일기 제목1",
                    "content": "오늘은…",
                    "diaryImgUrl": "https…",
                    "status": "NORMAL",
                  }
                }
                """.data(using: .utf8)!

            case .moveToTrash:
                // 휴지통 이동 성공 응답
                return """
                {
                  "isSuccess": true,
                  "code": "COMMON200",
                  "message": "성공입니다.",
                }
                """.data(using: .utf8)!

            case .deletePermanently:
                // 영구 삭제 성공 응답
                return """
                {
                  "isSuccess": true,
                  "code": "COMMON200",
                  "message": "일기 영구 삭제 성공",
                }
                """.data(using: .utf8)!

            case .searchDiary:
                // 검색 결과 리스트
                return """
                {
                "isSuccess": true,
                "code": "COMMON200",
                "message": "성공입니다.",
                    "result": {
                        "diaries": [
                          {
                            "diaryId": 1,
                            "diaryDate": "2025-06-20",
                            "title": "일기 제목 1",
                            "status": "NORMAL",
                            "emotion": "HAPPY",
                            "content": "일기 내용"
                        },
                        {
                            "diaryId": 2,
                            "diaryDate": "2025-06-21",
                            "title": "일기 제목 2",
                            "status": "SCRAP",
                            "emotion": "SAD",
                            "content": "일기 내용"
                        }
                    ],
                    "hasNext": true,
                    "nextCursor": “2025-06-21”,
                    ”total": 2
                  }
                }

                """.data(using: .utf8)!

            case .scrapOn(let id):
                // 스크랩 성공 응답
                return """
                {
                  "isSuccess": true,
                  "code": "COMMON200",
                  "message": "성공입니다.",
                }
                """.data(using: .utf8)!

            case .scrapOff(let id):
                // 스크랩 취소 응답
                return """
                {
                  "isSuccess": true,
                  "code": "COMMON200",
                  "message": "성공입니다.",
                }
                """.data(using: .utf8)!

            case .tempStatus(let ids):
                // 임시보관 응답
                return """
                {
                  "isSuccess": true,
                  "code": "COMMON200",
                  "message": "성공입니다."
                }
                """.data(using: .utf8)!
            }
        }
}

