//
//  DiaryStepView.swift
//  Plantory
//
//  Created by 김지우 on 8/14/25.
//

import SwiftUI

struct DiaryStepView: View {
    @Bindable var vm: AddDiaryViewModel
    let maxLength: Int = 300
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        

        VStack {
            
            Text("오늘은 어떤 일이 있었나요?")
                .font(.pretendardSemiBold(20))
                .foregroundStyle(.diaryfont)
                .multilineTextAlignment(.center)
                .padding(.bottom, 30)
            
            
            HStack {
                Spacer()
                Text("\(vm.content.count)/\(maxLength)")
                    .foregroundColor(vm.content.count > maxLength ? .red : .gray)
                    .font(.caption)
            }//HStack_end
            .padding(.horizontal,30)
            
            ZStack(alignment: .topLeading) {
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color.white01)
                    .stroke(colorScheme == .dark ? Color.clear : Color.green04, lineWidth: 1)
                
                TextEditor(text: $vm.content)
                
                    .font(.pretendardRegular(16))
                    .foregroundStyle(.black01)
                    .background(Color.clear)
                    .scrollContentBackground(.hidden)
                    .onChange(of: vm.content) { newValue in
                        if newValue.count > maxLength {
                            vm.content = String(newValue.prefix(maxLength))
                        }
                    }
            }
            .frame(maxWidth: .infinity, maxHeight: 376)
            .padding(.horizontal, 20)
            
        }
    }
}

#Preview{
    DiaryStepView(vm: AddDiaryViewModel(container: DIContainer()))

}
