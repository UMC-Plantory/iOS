//
//  ProfileService.swift
//  Plantory
//
//  Created by 이효주 on 8/14/25.
//

import Foundation
import CombineMoya
import Moya
import Combine

// 정렬 옵션
public enum SortOrder: String {
    case oldest
    case latest
}

// MARK: - Profile 서비스 프로토콜
protocol ProfileServiceProtocol {

    // 통계
    func fetchWeeklyStats() -> AnyPublisher<WeeklySleepResponse, APIError>
    func fetchMonthlyStats() -> AnyPublisher<MonthlySleepResponse, APIError>
    func fetchWeeklyEmotionStats() -> AnyPublisher<EmotionStatsResponse, APIError>
    func fetchMonthlyEmotionStats() -> AnyPublisher<EmotionStatsResponse, APIError>

    // 임시 보관함 / 휴지통
    func fetchTemp(sort: SortOrder) -> AnyPublisher<[Diary], APIError>
    func fetchWaste(sort: SortOrder) -> AnyPublisher<[Diary], APIError>
    func patchWaste(diaryIds: [Int]) -> AnyPublisher<WastePatchResponse, APIError>
    func deleteWaste(diaryIds: [Int]) -> AnyPublisher<WasteDeleteResponse, APIError>

    // 프로필
    func fetchProfile(memberId: UUID) -> AnyPublisher<FetchProfileResponse, APIError>
    func patchProfile(
        memberId: UUID,
        name: String,
        profileImgUrl: String,
        gender: String,
        birth: String
    ) -> AnyPublisher<PatchProfileResponse, APIError>
}

// MARK: - Profile API를 사용하는 서비스
final class ProfileService: ProfileServiceProtocol {

    // MoyaProvider
    let provider: MoyaProvider<ProfileRouter>

    // MARK: Initializer
    init(provider: MoyaProvider<ProfileRouter> = APIManager.shared.createProvider(for: ProfileRouter.self)) {
        self.provider = provider
    }

    // MARK: - 통계
    // 수면 통계
    func fetchWeeklyStats() -> AnyPublisher<WeeklySleepResponse, APIError> {
        let today = DateFormatter.yyyyMMdd.string(from: Date())
        return provider.requestResult(
            .weeklyStats(today: today), type: WeeklySleepResponse.self
        )
    }

    func fetchMonthlyStats() -> AnyPublisher<MonthlySleepResponse, APIError> {
            let today = DateFormatter.yyyyMMdd.string(from: Date())
            return provider.requestResult(.monthlyStats(today: today), type: MonthlySleepResponse.self)
    }

    // 감정통계
    func fetchWeeklyEmotionStats() -> AnyPublisher<EmotionStatsResponse, APIError> {
        let today = DateFormatter.yyyyMMdd.string(from: Date())
        return provider.requestResult(.weeklyEmotionStats(today: today), type: EmotionStatsResponse.self)
    }
    
    func fetchMonthlyEmotionStats() -> AnyPublisher<EmotionStatsResponse, APIError> {
        let today = DateFormatter.yyyyMMdd.string(from: Date())
        return provider.requestResult(.monthlyEmotionStats(today: today), type: EmotionStatsResponse.self)
    }

    // MARK: - 임시 보관함 / 휴지통
    func fetchTemp(sort: SortOrder = .latest) -> AnyPublisher<[Diary], APIError> {
        provider.requestResult(.temporary(sort: sort.rawValue), type: TempResponse.self)
            .map(\.diaries)
            .eraseToAnyPublisher()
    }

    func fetchWaste(sort: SortOrder = .latest) -> AnyPublisher<[Diary], APIError> {
        provider.requestResult(.waste(sort: sort.rawValue), type: WasteResponse.self)
            .map(\.diaries)
            .eraseToAnyPublisher()
    }

    func patchWaste(diaryIds: [Int]) -> AnyPublisher<WastePatchResponse, APIError> {
        provider.requestResult(.wastePatch(diaryIds: diaryIds), type: WastePatchResponse.self)
    }

    func deleteWaste(diaryIds: [Int]) -> AnyPublisher<WasteDeleteResponse, APIError> {
        // NOTE: 기존 파일에 wastePatch로 요청하던 부분을 wasteDelete로 수정
        provider.requestResult(.deleteDiary(diaryIds: diaryIds), type: WasteDeleteResponse.self)
    }

    // MARK: - 프로필
    func fetchProfile(memberId: UUID) -> AnyPublisher<FetchProfileResponse, APIError> {
        provider.requestResult(.fetchProfile(memberId: memberId), type: FetchProfileResponse.self)
    }

    func patchProfile(
        memberId: UUID,
        name: String,
        profileImgUrl: String,
        gender: String,
        birth: String
    ) -> AnyPublisher<PatchProfileResponse, APIError> {
        provider.requestResult(
            .patchProfile(
                memberId: memberId,
                name: name,
                profileImgUrl: profileImgUrl,
                gender: gender,
                birth: birth
            ),
            type: PatchProfileResponse.self
        )
    }
}

extension DateFormatter {
    static let yyyyMMdd: DateFormatter = {
        let df = DateFormatter()
        df.dateFormat = "yyyy-MM-dd"
        return df
    }()
}
