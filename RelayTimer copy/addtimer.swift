//
//  addtimer.swift
//  RelayTimer
//
//  Created by 福田光一郎 on 2026/03/12.
//

import SwiftUI
import UserNotifications

enum ActiveSheet: Identifiable {
    case newTimer
    case timerSet
    
    var id: Int { hashValue }
}

struct addtimer: View {
    var editingTimerSet: TimerSet? = nil
    
    @State private var title = ""
    @State private var notification = true
    @State private var time = Date()
    
    @State private var showMenu = false
    @State private var activeSheet: ActiveSheet?
    @State private var editingTimer: TimerItem?
    @State private var selectedSingleTimer: TimerItem?
    
    @Binding var timerSets: [TimerSet]
    @Environment(\.dismiss) private var dismiss
    @State private var timers: [TimerItem] = []
    
    private var totalTimeText: String {
        let totalSeconds = timers.reduce(0) { $0 + $1.time }
        let hours = totalSeconds / 3600
        let minutes = (totalSeconds % 3600) / 60
        let seconds = totalSeconds % 60

        if hours > 0 {
            return String(format: "%d:%02d:%02d", hours, minutes, seconds)
        } else {
            return String(format: "%d:%02d", minutes, seconds)
        }
    }
    
    private func requestNotificationPermissionAndSchedule() {
        let center = UNUserNotificationCenter.current()

        center.getNotificationSettings { settings in
            switch settings.authorizationStatus {
            case .authorized, .provisional, .ephemeral:
                scheduleNotification()
            case .notDetermined:
                center.requestAuthorization(options: [.alert, .sound, .badge]) { granted, _ in
                    if granted {
                        scheduleNotification()
                    }
                }
            case .denied:
                break
            @unknown default:
                break
            }
        }
    }

    private func scheduleNotification() {
        let center = UNUserNotificationCenter.current()
        let content = UNMutableNotificationContent()
        content.title = title.isEmpty ? "RelayTimer" : title
        content.body = "\(title)設定した時間になりました。"
        content.sound = .default

        let calendar = Calendar.current
        let timeComponents = calendar.dateComponents([.hour, .minute], from: time)
        let now = Date()

        var scheduledDateComponents = calendar.dateComponents([.year, .month, .day], from: now)
        scheduledDateComponents.hour = timeComponents.hour
        scheduledDateComponents.minute = timeComponents.minute

        guard let scheduledDate = calendar.date(from: scheduledDateComponents) else { return }

        let finalDate: Date
        if scheduledDate <= now {
            finalDate = calendar.date(byAdding: .day, value: 1, to: scheduledDate) ?? scheduledDate
        } else {
            finalDate = scheduledDate
        }

        let finalComponents = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: finalDate)
        let trigger = UNCalendarNotificationTrigger(dateMatching: finalComponents, repeats: false)

        let request = UNNotificationRequest(
            identifier: UUID().uuidString,
            content: content,
            trigger: trigger
        )

        center.add(request)
    }
    
    private func binding(for timer: TimerItem) -> Binding<TimerItem> {
        guard let index = timers.firstIndex(where: { $0.id == timer.id }) else {
            fatalError("編集対象のタイマーが見つかりません")
        }
        return $timers[index]
    }

    var body: some View {
        ZStack(alignment: .bottom) {
            ScrollView {
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
                            HStack(alignment: .center, spacing: 12) {
                                Circle()
                                    .stroke(Color.black, lineWidth: 2)
                                    .frame(width: 60, height: 60)
                                Button {
                                    editingTimer = timer
                                } label: {
                                    HStack(spacing: 12) {
                                        VStack(alignment: .leading, spacing: 6) {
                                            Text(timer.name)
                                                .font(.title2)
                                                .foregroundStyle(.primary)

                                            Divider()
                                        }

                                        Spacer()

                                        Text(formatTime(timer.time))
                                            .font(.title2)
                                            .foregroundStyle(.primary)
                                    }
                                    .contentShape(Rectangle())
                                }
                                .buttonStyle(.plain)
                            }
                            .padding(.vertical, 12)
                            .padding(.horizontal)

                            if index < timers.count - 1 {
                                HStack {
                                    Rectangle()
                                        .fill(Color.black)
                                        .frame(width: 1)
                                        .frame(height: 50)
                                        .padding(.leading, 29)
                                    Spacer()
                                }
                            }
                        }
                    }
                    
                    
                    Spacer()
                    
                    
                    // 合計
                    HStack {
                        Spacer()
                        Text("合計: \(totalTimeText)")
                            .font(.title3)
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 120)
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
                .sheet(item: $editingTimer) { timer in
                    NavigationStack {
                        EditTimerView(timer: binding(for: timer))
                    }
                }
                .fullScreenCover(item: $selectedSingleTimer) { timer in
                    NavigationStack {
                        TimerView(
                            timerSet: TimerSet(
                                name: timer.name,
                                timers: [timer]
                            )
                        )
                    }
                }
            }
            .onAppear {
                if let editingTimerSet {
                    title = editingTimerSet.name
                    timers = editingTimerSet.timers
                }
            }
            .toolbar {
                Button("保存") {

                    if let editingTimerSet,
                       let index = timerSets.firstIndex(where: { $0.id == editingTimerSet.id }) {

                        timerSets[index].name = title
                        timerSets[index].timers = timers

                    } else {
                        let newSet = TimerSet(
                            name: title,
                            timers: timers
                        )
                        timerSets.append(newSet)
                    }

                    if notification {
                        requestNotificationPermissionAndSchedule()
                    }

                    dismiss()
                }
            }
            
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
    }
    func formatTime(_ seconds: Int) -> String {
        let minutes = seconds / 60
        let sec = seconds % 60
        return "\(minutes):\(String(format: "%02d", sec))"
    }
}


struct EditTimerView: View {
    @Binding var timer: TimerItem
    @Environment(\.dismiss) private var dismiss

    @State private var editedName: String = ""
    @State private var showTimePicker = false
    @State private var hours = 0
    @State private var minutes = 0
    @State private var seconds = 0

    private var totalSeconds: Int {
        hours * 3600 + minutes * 60 + seconds
    }

    private var formattedTime: String {
        String(format: "%02d:%02d:%02d", hours, minutes, seconds)
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("タイマー名")
                        .font(.headline)

                    TextField("タイマー名を入力", text: $editedName)
                        .textFieldStyle(.roundedBorder)
                }

                VStack(alignment: .leading, spacing: 12) {
                    Text("所要時間")
                        .font(.headline)

                    Button {
                        showTimePicker = true
                    } label: {
                        HStack {
                            Text(formattedTime)
                                .font(.title3.monospacedDigit())
                                .foregroundStyle(.primary)

                            Spacer()

                            Image(systemName: "chevron.up.chevron.down")
                                .font(.footnote)
                                .foregroundStyle(.secondary)
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 14)
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(Color(.secondarySystemBackground))
                        )
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(16)
        }
        .navigationTitle("タイマーを編集")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("保存") {
                    timer.name = editedName
                    timer.time = totalSeconds
                    dismiss()
                }
                .disabled(editedName.isEmpty || totalSeconds == 0)
            }
        }
        .sheet(isPresented: $showTimePicker) {
            NavigationStack {
                VStack(spacing: 16) {
                    Text(formattedTime)
                        .font(.title2.monospacedDigit())
                        .padding(.top, 8)

                    HStack(spacing: 8) {
                        VStack(spacing: 0) {
                            Picker("時間", selection: $hours) {
                                ForEach(0..<24) { Text("\($0)").tag($0) }
                            }
                            .labelsHidden()
                            .pickerStyle(.wheel)
                            .frame(height: 140)
                            .clipped()

                            Text("時間")
                                .font(.caption2)
                                .foregroundStyle(.secondary)
                        }
                        .frame(maxWidth: .infinity)

                        VStack(spacing: 0) {
                            Picker("分", selection: $minutes) {
                                ForEach(0..<60) { Text("\($0)").tag($0) }
                            }
                            .labelsHidden()
                            .pickerStyle(.wheel)
                            .frame(height: 140)
                            .clipped()

                            Text("分")
                                .font(.caption2)
                                .foregroundStyle(.secondary)
                        }
                        .frame(maxWidth: .infinity)

                        VStack(spacing: 0) {
                            Picker("秒", selection: $seconds) {
                                ForEach(0..<60) { Text("\($0)").tag($0) }
                            }
                            .labelsHidden()
                            .pickerStyle(.wheel)
                            .frame(height: 140)
                            .clipped()

                            Text("秒")
                                .font(.caption2)
                                .foregroundStyle(.secondary)
                        }
                        .frame(maxWidth: .infinity)
                    }
                    .padding(.horizontal, 8)
                    .padding(.vertical, 10)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color(.secondarySystemBackground))
                    )

                    Spacer()
                }
                .padding(16)
                .navigationTitle("所要時間")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button("完了") {
                            showTimePicker = false
                        }
                    }
                }
            }
            .presentationDetents([.medium])
        }
        .onAppear {
            editedName = timer.name
            hours = timer.time / 3600
            minutes = (timer.time % 3600) / 60
            seconds = timer.time % 60
        }
    }
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
