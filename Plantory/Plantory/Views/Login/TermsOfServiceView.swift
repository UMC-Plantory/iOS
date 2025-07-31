//
//  TermsOfServiceView.swift
//  Plantory
//
//  Created by 주민영 on 7/8/25.
//

import SwiftUI

struct TermsOfServiceView: View {
    @State var viewModel: PermitViewModel = PermitViewModel()
    
    var body: some View {
        HStack {
            VStack(alignment: .trailing) {
                VStack(alignment: .leading) {
                    topTextView
                    
                    VStack(alignment: .leading, spacing: 20) {
                        allToggle
                        
                        Divider()
                            .foregroundStyle(.gray06)
                        
                        detailedToggles
                    }
                    .padding(.top, 44)
                    
                    Spacer()
                        .frame(height: 168)
                }
                
                MainSmallButton(
                    text: "다음",
                    isDisabled: !(viewModel.fourteenPermit && viewModel.termsOfServicePermit && viewModel.informationPermit),
                    action: {
                        print("다음")
                    }
                )
                
                Spacer()
            }
            .padding(.horizontal, 16)
        }
        .padding(.top, 10)
        .customNavigation(
            leading:
                Button(action: {
                    print("뒤로가기")
                }, label: {
                    Image("leftChevron")
                        .fixedSize()
                })
        )
    }
    
    private var topTextView: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("서비스 이용 동의")
                .font(.pretendardSemiBold(24))
                .foregroundStyle(.black01)
            
            Text("약관을 확인 후 버튼을 체크해주세요")
                .font(.pretendardRegular(14))
                .foregroundStyle(.gray10)
        }
    }
    
    private var allToggle: some View {
        Toggle("약관 전체 동의", isOn: $viewModel.allPermit)
            .toggleStyle(CheckboxToggleStyle(style: .circle))
            .font(.pretendardSemiBold(18))
            .foregroundStyle(.black01)
    }
    
    private var detailedToggles: some View {
        VStack(alignment: .leading, spacing: 40) {
            ForEach(permitItems, id: \.id) { item in
                HStack {
                    Toggle(item.title, isOn: item.binding)
                        .toggleStyle(CheckboxToggleStyle(style: .circle))
                        .font(.pretendardRegular(16))
                        .foregroundStyle(.gray10)
                    
                    Spacer()
                    
                    if (item.showDetail) {
                        Button(action: {
                            // MARK: 이용약관 볼 수 있도록
                        }, label: {
                            Image("rightChevron")
                                .fixedSize()
                                .foregroundStyle(.gray10)
                        })
                    }
                }
            }
        }
        .padding(.top, 5)
    }
    
    var permitItems: [PermitItem] {
        [
            PermitItem(title: "(필수) 만 14세 이상입니다", showDetail: false, binding: $viewModel.fourteenPermit),
            PermitItem(title: "(필수) 서비스 이용약관", showDetail: true, binding: $viewModel.termsOfServicePermit),
            PermitItem(title: "(필수) 개인정보 수집/이용동의", showDetail: true, binding: $viewModel.informationPermit),
            PermitItem(title: "(선택) 위치정보 제공", showDetail: true, binding: $viewModel.locationPermit),
            PermitItem(title: "(선택) 마케팅 수신 동의", showDetail: true, binding: $viewModel.marketingPermit)
        ]
    }
}

#Preview {
    NavigationStack {
        TermsOfServiceView()
    }
}
