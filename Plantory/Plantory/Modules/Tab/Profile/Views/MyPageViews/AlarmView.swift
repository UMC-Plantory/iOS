//
//  AlarmView.swift
//  Plantory
//
//  Created by 이효주 on 10/6/25.
//

import SwiftUI

struct AlarmView: View {
    
    @State private var hour = 6
    @State private var isPM = true
    
    var body: some View {
        VStack {
            
            // MARK: - Header View
            HStack {
                Text("취소")
                    .font(.pretendardRegular(18))
                    .foregroundStyle(.green06)
                
                Spacer()
                
                Text("알람 설정")
                    .font(.pretendardBold(18))
                    .foregroundStyle(.black01Dynamic)
                
                Spacer()
                
                Text("저장")
                    .font(.pretendardRegular(18))
                    .foregroundStyle(.green06)
            }
            .padding(.horizontal, 32)
            .padding(.top, 30)
            .padding(.bottom, 26)
            
            Divider()
            
            FixedMinuteTimePicker_Custom(hour: $hour, isPM: $isPM,
                                         rowHeight: 43, columnSpacing: 30, lineColor: .green04)
            
        }
    }
}

#Preview {
    AlarmView()
}
