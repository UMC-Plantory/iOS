//
//  PlantPopupViewModel.swift
//  Plantory
//
//  Created by 박정환 on 8/11/25.
//

import Foundation
import Combine


@Observable
final class PlantPopupViewModel {
    // MARK: - UI State
    var isPresented = false
    var isLoading = false
    var errorMessage: String?

    // 서버 원본을 가공한 도메인 모델 (뷰에서 바로 사용)
    private(set) var detail: TerrariumDetail?

    // 선택된 테라리움 ID
    var terrariumId: Int?

    // MARK: - DI & Combine
    let container: DIContainer
    var cancellables = Set<AnyCancellable>()

    init(container: DIContainer) {
        self.container = container
    }

    // MARK: - Public API
    func open(terrariumId: Int) {
        reset()
        self.terrariumId = terrariumId
        self.isPresented = true
        fetchDetail()
    }

    func close() { isPresented = false }
    func refresh() { fetchDetail() }

    // MARK: - Derived (뷰에서 바로 사용)
    var flowerNameText: String {
        detail?.flowerName ?? ""
    }
    var feelingText: String {
        guard let emotion = detail?.mostEmotion else { return "" }
        switch emotion {
        case "HAPPY":   return "기쁨"
        case "AMAZING": return "놀람"
        case "SAD":     return "슬픔"
        case "SOSO":    return "그럭저럭"
        case "ANGRY":   return "화남"
        default:        return emotion
        }
    }
    var birthDateText: String {
        guard let d = detail?.startAt else { return "" }
        return Self.formatYMD(d)
    }
    var completeDateText: String {
        guard let d = detail?.bloomAt else { return "" }
        return Self.formatYMD(d)
    }
    var usedDateTexts: [String] {
        (detail?.usedDiaries ?? []).map { Self.formatMD($0.diaryDate) }
    }

    var usedDiaryIds: [Int] {
        (detail?.usedDiaries ?? []).map { $0.diaryId }
    }

    var usedDiaryItems: [(text: String, id: Int)] {
        (detail?.usedDiaries ?? []).map { (Self.formatMD($0.diaryDate), $0.diaryId) }
    }
    var stageTexts: [(String, String)] {
        guard let d = detail else { return [] }
        return [
            ("1단계", Self.formatMD(d.firstStepDate)),
            ("2단계", Self.formatMD(d.secondStepDate)),
            ("3단계", Self.formatMD(d.thirdStepDate))
        ]
    }

    // MARK: - Networking
    private func fetchDetail() {
        guard let terrariumId else { return }
        isLoading = true
        errorMessage = nil
        print("[PlantPopupVM] fetchDetail start — id=\(terrariumId)")

        container.useCaseService.terrariumService
            // Service가 APIResponse<TerrariumDetailRaw>에서 .map { $0.result } 해주어
            // TerrariumDetailRaw 를 직접 방출한다고 가정
            .getTerrariumDetail(terrariumId: terrariumId)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                if case .failure(let error) = completion {
                    self?.errorMessage = "상세 조회 실패: \(error.localizedDescription)"
                    self?.isLoading = false
                    print("[PlantPopupVM] fetchDetail failure — \(error.localizedDescription)")
                }
            } receiveValue: { [weak self] raw in
                guard let self else { return }
                print("[PlantPopupVM] fetchDetail success — raw=\(raw)")
                self.detail = Self.mapRawToDetail(raw)
                self.isLoading = false
                print("[PlantPopupVM] mapped detail=\(String(describing: self.detail))")
            }
            .store(in: &cancellables)
    }

    // MARK: - Helpers
    private func reset() {
        isLoading = false
        errorMessage = nil
        detail = nil
    }

    // MARK: - Date Formatting
    private static func formatMD(_ date: Date) -> String {
        let f = DateFormatter()
        f.dateFormat = "MM.dd"
        return f.string(from: date)
    }
    private static func formatYMD(_ date: Date) -> String {
        let f = DateFormatter()
        f.dateFormat = "yyyy.MM.dd"
        return f.string(from: date)
    }

    // MARK: - Date Mapping
    private static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        // 아래 parseDate에서 포맷을 매번 바꿔가며 사용
        return formatter
    }()

    private static func parseDate(_ str: String) -> Date {
        let fm = dateFormatter
        fm.dateFormat = "yyyy-MM-dd"
        if let d = fm.date(from: str) { return d }
        fm.dateFormat = "yyyy.MM.dd"
        if let d = fm.date(from: str) { return d }
        assertionFailure("Invalid date string: \(str)")
        return Date(timeIntervalSince1970: 0)
    }

    // MARK: - Mapping
    /// API 원본(TerrariumDetailRaw) → 화면 도메인(TerrariumDetail)
    private static func mapRawToDetail(_ raw: TerrariumDetailRaw) -> TerrariumDetail {
        return TerrariumDetail(
            flowerName: raw.flowerName,
            startAt: parseDate(raw.startAt),
            bloomAt: parseDate(raw.bloomAt),
            mostEmotion: raw.mostEmotion,
            usedDiaries: raw.usedDiaries.map { UsedDiary(diaryDate: parseDate($0.diaryDate), diaryId: $0.diaryId) },
            firstStepDate: parseDate(raw.firstStepDate),
            secondStepDate: parseDate(raw.secondStepDate),
            thirdStepDate: parseDate(raw.thirdStepDate)
        )
    }
}
