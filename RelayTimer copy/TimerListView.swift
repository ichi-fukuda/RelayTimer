//
//  TimerListView.swift
//  RelayTimer
//
//  Created by 福田光一郎 on 2026/03/04.
//

import SwiftUI

struct TimerItem: Identifiable {
    let id = UUID()
    var name: String
    var time: Int   // 秒
}

struct TimerSet: Identifiable {
    let id = UUID()
    var name: String
    var timers: [TimerItem]
}

struct TimerListView: View {
    
    @State var timerSets: [TimerSet] = []
    
    @State private var searchText = ""
    
    var body: some View {
        
        NavigationStack {
            
            List(timerSets) { timer in
                
                HStack {
                    
                    Text(timer.name)
                        .font(.system(size: 40))
                    
                    Spacer()
                    
                    NavigationLink(destination: TimerView(timerSet: timer)) {
                        Image(systemName: "play.fill")
                            .foregroundStyle(.white)
                            .frame(width: 60, height: 60)
                            .background(.pink)
                            .clipShape(Circle())
                    }
                }
                .padding(.vertical, 10)
            }
            
            .navigationTitle("タイマーセット一覧")
            .navigationBarTitleDisplayMode(.large)
            .searchable(text: $searchText)
            
            
            // ＋ボタン
            .overlay(alignment: .bottomTrailing) {
                
                NavigationLink(destination: addtimer(timerSets: $timerSets)) {
                    Image(systemName: "plus")
                        .font(.system(size: 25))
                        .foregroundStyle(.white)
                        .frame(width: 70, height: 70)
                        .background(.gray.opacity(0.3))
                        .clipShape(Circle())
                        .padding()
                }
            }
        }
    }
}

#Preview {
    TimerListView(timerSets: [
        TimerSet(
            name: "朝の支度",
            timers: [
                TimerItem(name: "歯磨き", time: 120),
                TimerItem(name: "朝食", time: 600)
            ]
        )
    ])
}
