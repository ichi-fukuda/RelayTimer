//
//  addtimer.swift
//  RelayTimer
//
//  Created by 福田光一郎 on 2026/03/12.
//

import SwiftUI

enum ActiveSheet: Identifiable {
    case newTimer
    case timerSet
    
    var id: Int { hashValue }
}

struct addtimer: View {
    
    @State private var title = ""
    @State private var notification = true
    @State private var time = Date()
    
    @State private var showMenu = false
    @State private var activeSheet: ActiveSheet?
    
    @Binding var timerSets: [TimerSet]
    @State private var timers: [TimerItem] = []
    
    var body: some View {
        
        VStack(spacing: 20) {
            
            // タイトル
            TextField("Title", text: $title)
                .textFieldStyle(.roundedBorder)
                .padding(.horizontal)
            
            
            // 通知
            HStack {
                Image(systemName: "bell.fill")
                
                Text("通知")
                
                Spacer()
                
                Toggle("", isOn: $notification)
                    .labelsHidden()
            }
            .padding(.horizontal)
            
            
            // 時間
            HStack {
                Text("時間")
                Spacer()
                
                DatePicker("", selection: $time, displayedComponents: .hourAndMinute)
                    .labelsHidden()
            }
            .padding(.horizontal)
            
            
            Divider()
            
            
            // タイマーリスト
            VStack(spacing: 0) {
                ForEach(Array(timers.enumerated()), id: \.element.id) { index, timer in
                    TimerRow(
                        name: timer.name,
                        time: formatTime(timer.time)
                    )
                    .padding(.vertical, 12)

                    if index < timers.count - 1 {
                        HStack {
                            Rectangle()
                                .fill(Color.black)
                                .frame(width: 1)
                                .frame(height: 50)
                                .padding(.leading, 45) // 円の中央に合わせて調整
                            Spacer()
                        }
                    }
                }
            }
            
            
            Spacer()
            
            
            // 合計
            HStack {
                Spacer()
                Text("合計:20:00")
                    .font(.title3)
            }
            .padding(.horizontal)
            
        }
        .navigationTitle("新規タイマーセット")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(item: $activeSheet) { sheet in
            NavigationStack {
                switch sheet {
                case .newTimer:
                    NewTimerView(timers: $timers)

                case .timerSet:
                    NewTimerSetView()
                }
            }
        }
        
        // ＋ボタン
        .overlay(alignment: .bottom) {

            Menu {
                Button("新規タイマー") {
                    activeSheet = .newTimer
                }

                Button("タイマーセットを追加") {
                    activeSheet = .timerSet
                }

            } label: {
                Image(systemName: "plus")
                    .font(.system(size: 30))
                    .foregroundColor(.white)
                    .frame(width: 70, height: 70)
                    .background(.red)
                    .clipShape(Circle())
            }
            .padding(.bottom, 30)
        }
        .toolbar {
            Button("保存") {
                let newSet = TimerSet(
                    name: title,
                    timers: timers
                )
                
                timerSets.append(newSet)
            }
        }
        
//        .confirmationDialog("追加", isPresented: $showMenu) {
//            
//            Button("新規タイマー") {
//                activeSheet = .newTimer
//            }
//            
//            Button("タイマーセットを追加") {
//                activeSheet = .timerSet
//            }
//        }
    }
}
func formatTime(_ seconds: Int) -> String {
    let minutes = seconds / 60
    let sec = seconds % 60
    return "\(minutes):\(String(format: "%02d", sec))"
}

#Preview {
    NavigationStack {
        addtimer(timerSets: .constant([
            TimerSet(
                name: "朝の支度",
                timers: [
                    TimerItem(name: "歯磨き", time: 120),
                    TimerItem(name: "朝食", time: 600)
                ]
            )
        ]))
    }
}
