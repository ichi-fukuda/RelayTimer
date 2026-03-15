//
//  FinishView.swift
//  RelayTimer
//
//  Created by 福田光一郎 on 2026/03/14.
//

import SwiftUI

struct FinishView: View {
    var body: some View {
        NavigationStack {  // NavigationStackでラップする
            VStack {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundStyle(.red)
                    .frame(width: 100, height: 100)
                    .font(.system(size: 70))

                Text("DONE")
                    .font(.system(size: 70))

                // 「閉じる」をタップすると TimerListView へ遷移
                NavigationLink(destination: TimerListView()) {
                    Text("閉じる")
                }
                .buttonStyle(.borderedProminent)
            }
            .navigationBarBackButtonHidden(true) // 戻るボタンを非表示
        }
    }
}

#Preview {
    FinishView()
}
