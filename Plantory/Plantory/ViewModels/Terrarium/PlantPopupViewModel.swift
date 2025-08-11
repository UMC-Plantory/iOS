//
//  PlantPopupViewModel.swift
//  Plantory
//
//  Created by 박정환 on 8/11/25.
//

import Foundation

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
    var isPresented: Bool = false
    var plantName: String = ""
    var feeling: String = ""
    var birthDate: String = ""
    var completeDate: String = ""
    var usedDates: [String] = []
    var stages: [(String, String)] = []   // (단계명, 날짜)

    // 보조 상태
    var isLoading: Bool = false
    var errorMessage: String?

    // 현재 상세 조회 중인 테라리움 ID (재시도/리프레시용)
    var terrariumId: Int?

    // MARK: - DI & Combine
    let container: DIContainer
    var cancellables = Set<AnyCancellable>()

    // MARK: - Init
    init(container: DIContainer) {
        self.container = container
    }

    // MARK: - Public API
    func open(terrariumId: Int, name: String) {
        reset()
        self.terrariumId = terrariumId
        self.plantName = name
        self.isPresented = true
        fetchDetail()
    }

    func close() {
        isPresented = false
    }

    func refresh() {
        fetchDetail()
    }

    // MARK: - Networking
    private func fetchDetail() {
        guard let terrariumId else { return }
        isLoading = true
        errorMessage = nil

        container.useCaseService.terrariumService
            .getTerrariumDetail(terrariumId: terrariumId)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] completion in
                if case .failure(let error) = completion {
                    self?.errorMessage = "상세 조회 실패: \(error.localizedDescription)"
                    self?.isLoading = false
                }
            }, receiveValue: { [weak self] response in
                let dto = response.result
                self?.feeling = dto.mostEmotion
                self?.birthDate = Self.trim(dto.startAt)
                self?.completeDate = Self.trim(dto.bloomAt)
                self?.usedDates = dto.usedDiaries.map(Self.trim)
                self?.stages = [
                    ("1단계", Self.trim(dto.firstStepDate)),
                    ("2단계", Self.trim(dto.secondStepDate)),
                    ("3단계", Self.trim(dto.thirdStepDate))
                ]
                self?.isLoading = false
            })
            .store(in: &cancellables)
    }

    // MARK: - Helpers
    private func reset() {
        isLoading = false
        errorMessage = nil
        feeling = ""
        birthDate = ""
        completeDate = ""
        usedDates = []
        stages = []
    }

    /// ISO8601(혹은 yyyy-MM-ddTHH:mm:ss) 문자열에서 앞 10자리(yyyy-MM-dd)만 사용
    private static func trim(_ s: String) -> String {
        s.count >= 10 ? String(s.prefix(10)) : s
    }
}
