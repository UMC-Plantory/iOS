import SwiftUI
import PhotosUI
import UniformTypeIdentifiers
import ImageIO

struct PhotoStepView: View {
    @Bindable var vm: AddDiaryViewModel
    @State private var selectedItems: [PhotosPickerItem] = []
    @State private var selectedImages: [UIImage] = []

    // 고정 박스 크기 (디자인 기준)
    private let boxSize = CGSize(width: 205, height: 207)

    var body: some View {
        
        VStack {
            Text("오늘의 사진을 선택한다면 무엇인가요?")
                .font(.pretendardSemiBold(20))
                .foregroundStyle(.adddiaryfont)
                .multilineTextAlignment(.center)
                .padding(.bottom, 64)

            ZStack {
                // 배경 박스
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color.gray04)
                    .frame(width: boxSize.width, height: boxSize.height)

                // 이미지 표시 (있을 때만)
                if let firstImage = selectedImages.first {
                    Image(uiImage: firstImage)
                        .resizable()
                        .scaledToFill()
                        .frame(width: boxSize.width, height: boxSize.height) // ← 정확히 고정
                        .clipped()
                        .cornerRadius(10)
                        .transition(.opacity)
                }

                // 사진 선택 버튼 (이미지 없을 때만 터치 가능)
                if selectedImages.isEmpty {
                    PhotosPicker(selection: $selectedItems,
                                 maxSelectionCount: 5,
                                 matching: .images) {
                        VStack {
                            Image(.photo)
                                .resizable()
                                .frame(width: 32, height: 32)
                            Text("사진을 업로드해 주세요")
                                .font(.pretendardRegular(16))
                                .foregroundStyle(.gray08)
                        }
                        .frame(width: boxSize.width, height: boxSize.height)
                    }
                    .zIndex(1)
                }
            }
            Spacer()
            
        }
        .padding()

        // 선택 아이템 변경 시: 다운샘플링해서 로드
        .onChange(of: selectedItems) { _, newItems in
            selectedImages.removeAll()

            for item in newItems {
                Task.detached(priority: .userInitiated) {
                    guard let data = try? await item.loadTransferable(type: Data.self) else { return }
                    // 박스보다 약간 큰 픽셀로 다운샘플링 (배율 고려해서 2x)
                    let target = max(boxSize.width, boxSize.height) * 2.0
                    if let image = downsample(data: data, maxPixel: target) {
                        await MainActor.run {
                            selectedImages.append(image)
                            if selectedImages.first == image {
                                vm.setImage(image) // 첫 장을 업로드 대상으로 사용
                            }
                        }
                    }
                }
            }
        }

        // 선택 이미지 배열 자체가 바뀔 때 VM에 싱크
        .onChange(of: selectedImages) { _, imgs in
            if let first = imgs.first {
                vm.setImage(first)
            } else {
                vm.setImage(nil)
            }
        }

    }
}

// MARK: - 다운샘플링 유틸
private func downsample(data: Data, maxPixel: CGFloat) -> UIImage? {
    let options: [CFString: Any] = [
        kCGImageSourceShouldCache: false,
        kCGImageSourceTypeIdentifierHint: UTType.jpeg.identifier as CFString
    ]
    guard let src = CGImageSourceCreateWithData(data as CFData, options as CFDictionary) else { return nil }

    let downOptions: [CFString: Any] = [
        kCGImageSourceCreateThumbnailFromImageAlways: true,
        kCGImageSourceShouldCacheImmediately: true,
        kCGImageSourceCreateThumbnailWithTransform: true,
        kCGImageSourceThumbnailMaxPixelSize: Int(maxPixel)
    ]

    guard let cgImg = CGImageSourceCreateThumbnailAtIndex(src, 0, downOptions as CFDictionary) else { return nil }
    return UIImage(cgImage: cgImg)
}

#Preview{
    PhotoStepView(vm: AddDiaryViewModel(container: DIContainer()))
}
