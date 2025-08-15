//
//  ProfileInfoViewModel.swift
//  Plantory
//
//  Created by 주민영 on 8/9/25.
//

import SwiftUI
import Combine
import Moya

class ProfileInfoViewModel: ObservableObject {
    
    // MARK: - Toast
    
    @Published var toast: CustomToast? = nil
    
    // MARK: - 로딩
    
    @Published var isLoading = false
    
    // MARK: - 의존성 주입 및 비동기 처리

    /// DIContainer를 통해 의존성 주입
    let container: DIContainer
    /// Combine 구독 해제를 위한 Set
    var cancellables = Set<AnyCancellable>()

    // MARK: - Form Inputs
    
    @Published var selectedImage: UIImage? = nil
    @Published var name = ""
    @Published var id = ""
    @Published var birth = ""
    @Published var gender = ""

    // MARK: - Validation States
    
    @Published var nameState: FieldState = .normal
    @Published var idState: FieldState = .normal
    @Published var birthState: FieldState = .normal
    @Published var genderState: FieldState = .normal
    
    // MARK: - States
    
    // 버튼 조건 확인용
    @Published var isFormValid = false
    
    // 개인정보 입력 완료 확인용
    @Published var isCompleted: Bool = false
    
    // MARK: - Init
    
    /// ViewModel 초기화
    /// - Parameters:
    ///   - container: DIContainer를 주입받아 서비스 사용
    ///
    ///   setupValidationBindings으로 InputField 조건 검증
    init(container: DIContainer) {
        self.container = container
        
        self.setupValidationBindings()
    }

    // MARK: - Validation Setup
    
    private func setupValidationBindings() {
        $name.map(Self.validateName).assign(to: &$nameState)
        $id.map(Self.validateID).assign(to: &$idState)
        $birth.map(Self.validateBirthDate).assign(to: &$birthState)
        
        // 버튼 활성화 조건
        let firstFour = Publishers.CombineLatest4($selectedImage, $nameState, $idState, $birthState)
        Publishers.CombineLatest(firstFour, $gender)
            .map { (firstFourValues, gender) in
                let (image, nameState, idState, birthState) = firstFourValues
                
                guard image != nil else { return false }
                guard case .success = nameState else { return false }
                guard case .success = idState else { return false }
                guard case .success = birthState else { return false }
                guard !gender.isEmpty else { return false }
                return true
            }
            .assign(to: &$isFormValid)
    }

    // MARK: - Validation Methods
    
    private static func validateName(_ input: String) -> FieldState {
        guard !input.isEmpty else { return .normal }
        return input.count >= 2 && input.count <= 20
            ? .success(message: "해당 닉네임으로 설정이 가능합니다.")
            : .error(message: "닉네임은 2자 이상, 20자 이내로 설정해주세요.")
    }

    private static func validateID(_ input: String) -> FieldState {
        guard !input.isEmpty else { return .normal }
        let regex = "^[A-Za-z0-9_]{2,20}$"
        return input.range(of: regex, options: .regularExpression) != nil
            ? .success(message: "해당 아이디로 설정이 가능합니다.")
            : .error(message: "아이디는 2자 이상, 20자 이내로 설정해주세요.")
    }

    private static func validateBirthDate(_ input: String) -> FieldState {
        guard !input.isEmpty else { return .normal }
        let regex = #"^\d{4}-\d{2}-\d{2}$"#
        return input.range(of: regex, options: .regularExpression) != nil
            ? .success(message: "해당 생년월일로 설정이 가능합니다.")
            : .error(message: "생년월일 입력 양식은 0000-00-00을 따라야 합니다.")
    }
    
    // MARK: - API
    
    /// Presigned URL을 받아오는 API 호출
    func generatePresignedURL() async throws {
        self.isLoading = true
        
        let request = PresignedRequest(
            type: .profile,
            fileName: "profile.jpg"
        )
        
        container.useCaseService.imageService.generatePresignedURL(request: request)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] completion in
                if case .failure(let error) = completion {
                    self?.toast = CustomToast(
                        title: "이미지 업로드 에러",
                        message: "\(error.errorDescription ?? "알 수 없는 에러")"
                    )
                    print("로그인 오류: \(error.errorDescription ?? "알 수 없는 에러")")
                    self?.isLoading = false
                }
            }, receiveValue: { [weak self] response in
                // url을 성공적으로 받아오면 사진 업로드 API 요청
                _Concurrency.Task {
                    try await self?.putImage(urls: response)
                }
            })
            .store(in: &cancellables)
    }
    
    private func putImage(urls: PresignedResponse) async throws {
        guard let selectedImage = selectedImage else { return }

        if let data = selectedImage.jpegData(compressionQuality: 0.8) {
            container.useCaseService.imageService.putImage(presignedURL: urls.presignedUrl, data: data)
                .receive(on: DispatchQueue.main)
                .sink(receiveCompletion: { [weak self] completion in
                    if case .failure(let error) = completion {
                        self?.toast = CustomToast(
                            title: "이미지 업로드 에러",
                            message: "\(error.errorDescription ?? "알 수 없는 에러")"
                        )
                        print("로그인 오류: \(error.errorDescription ?? "알 수 없는 에러")")
                        self?.isLoading = false
                    }
                }, receiveValue: { [weak self] response in
                    // 이미지를 성공적으로 업로드한다면, 회원가입 완료 API 호출
                    _Concurrency.Task {
                        try await self?.patchSignup(profileImgUrl: urls.accessUrl)
                    }
                })
                .store(in: &cancellables)
        }
    }
    
    private func patchSignup(profileImgUrl: String) async throws {
        let request = SignupRequest(
            nickname: name,
            userCustomId: id,
            gender: gender == "남성" ? "MALE" : gender == "여성" ? "FEMALE" : "NONE",
            birth: birth,
            profileImgUrl: profileImgUrl
        )
        
        container.useCaseService.authService.patchSignup(request: request)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] completion in
                if case .failure(let error) = completion {
                    self?.toast = CustomToast(
                        title: "로그인 오류",
                        message: "\(error.errorDescription ?? "알 수 없는 에러")"
                    )
                    print("로그인 오류: \(error.errorDescription ?? "알 수 없는 에러")")
                    self?.isLoading = false
                }
            }, receiveValue: { [weak self] response in
                withAnimation {
                    self?.isCompleted = true
                }
                self?.isLoading = false
            })
            .store(in: &cancellables)
    }
}
