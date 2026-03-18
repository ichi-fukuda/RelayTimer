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
    init(editingTimerSet: TimerSet? = nil, timerSets: Binding<[TimerSet]>) {
        self.editingTimerSet = editingTimerSet
        self._timerSets = timerSets

        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor.red
        appearance.backgroundEffect = nil
        appearance.shadowColor = nil
        appearance.titleTextAttributes = [.foregroundColor: UIColor.white]
        appearance.largeTitleTextAttributes = [.foregroundColor: UIColor.white]

        let navigationBar = UINavigationBar.appearance()
        navigationBar.isTranslucent = false
        navigationBar.standardAppearance = appearance
        navigationBar.scrollEdgeAppearance = appearance
        navigationBar.compactAppearance = appearance
        navigationBar.tintColor = UIColor.white
    }

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
    @State private var childTimerSets: [TimerSet] = []
    @State private var orderedItems: [TimerSetOrderItem] = []
    
    private var totalTimeText: String {
        let totalSeconds = timers.reduce(0) { $0 + $1.time } + childTimerSets.reduce(0) { $0 + totalDuration(for: $1) }
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

    private enum OrderedEditorItem: Identifiable {
        case timer(TimerItem)
        case timerSet(TimerSet)

        var id: UUID {
            switch self {
            case .timer(let timer):
                return timer.id
            case .timerSet(let timerSet):
                return timerSet.id
            }
        }
    }

    private var availableChildTimerSets: [TimerSet] {
        let excludedIDs = Set(childTimerSets.map(\.id)).union(editingTimerSet.map { [$0.id] } ?? [])
        return timerSets.filter { !excludedIDs.contains($0.id) }
    }

    private var orderedEditorItems: [OrderedEditorItem] {
        orderedItems.compactMap { item in
            switch item.kind {
            case .timer:
                return timers.first(where: { $0.id == item.id }).map(OrderedEditorItem.timer)
            case .timerSet:
                return childTimerSets.first(where: { $0.id == item.id }).map(OrderedEditorItem.timerSet)
            }
        }
    }

    var body: some View {
        ZStack(alignment: .bottom) {
            ScrollView {
                VStack(spacing: 20) {
                    Spacer()
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
                    
                    
                    VStack(alignment: .leading, spacing: 12) {
                        if !orderedEditorItems.isEmpty {
                            Text("工程")
                                .font(.headline)
                                .foregroundStyle(.black)
                                .padding(.horizontal)
                        }

                        ForEach(Array(orderedEditorItems.enumerated()), id: \.element.id) { index, item in
                            orderedItemRow(for: item, at: index)
                        }
                    }
                    
                    
                    Spacer()
                    
                    
                    // 合計
                    HStack {
                        Spacer()
                        Text("合計: \(totalTimeText)")
                            .font(.title3)
                            .foregroundStyle(.black)
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 120)
                }
                .navigationTitle("新規タイマーセット")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .principal) {
                        Text("新規タイマーセット")
                            .font(.headline)
                            .foregroundStyle(.white)
                    }
                }
                .toolbarBackground(Color.red, for: .navigationBar)
                .toolbarBackground(.visible, for: .navigationBar)
                .tint(.white)
                .sheet(item: $activeSheet) { sheet in
                    NavigationStack {
                        switch sheet {
                        case .newTimer:
                            NewTimerView(timers: $timers)
                            
                        case .timerSet:
                            NewTimerSetView(
                                availableTimerSets: availableChildTimerSets,
                                selectedTimerSets: $childTimerSets
                            )
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
                    childTimerSets = editingTimerSet.childTimerSets
                    orderedItems = editingTimerSet.resolvedOrderedItems
                } else {
                    syncOrderedItems()
                }
            }
            .onChange(of: timers) { _, _ in
                syncOrderedItems()
            }
            .onChange(of: childTimerSets) { _, _ in
                syncOrderedItems()
            }
            .toolbar {
                Button("保存") {

                    if let editingTimerSet,
                       let index = timerSets.firstIndex(where: { $0.id == editingTimerSet.id }) {

                        timerSets[index].name = title
                        timerSets[index].timers = timers
                        timerSets[index].childTimerSets = childTimerSets
                        timerSets[index].orderedItems = orderedItems

                    } else {
                        let newSet = TimerSet(
                            name: title,
                            timers: timers,
                            childTimerSets: childTimerSets,
                            orderedItems: orderedItems
                        )
                        timerSets.append(newSet)
                    }

                    if notification {
                        requestNotificationPermissionAndSchedule()
                    }

                    dismiss()
                }
                .foregroundStyle(.white)
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
        .appBackground()
    }

    @ViewBuilder
    private func orderedItemRow(for item: OrderedEditorItem, at index: Int) -> some View {
        HStack(alignment: .center, spacing: 12) {
            rowLeadingIcon(for: item)

            Button {
                if case .timer(let timer) = item {
                    editingTimer = timer
                }
            } label: {
                HStack(spacing: 12) {
                    VStack(alignment: .leading, spacing: 6) {
                        Text(titleText(for: item))
                            .font(.title2)
                            .foregroundStyle(.black)

                        Text(subtitleText(for: item))
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                    }

                    Spacer()

                    if case .timer(let timer) = item {
                        Text(formatTime(timer.time))
                            .font(.title2)
                            .foregroundStyle(.black)
                    }
                }
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .disabled(!isEditable(item))

            VStack(spacing: 10) {
                Button {
                    moveOrderedItem(at: index, offset: -1)
                } label: {
                    Image(systemName: "chevron.up")
                        .foregroundStyle(index == 0 ? .gray : .black)
                }
                .disabled(index == 0)

                Button {
                    moveOrderedItem(at: index, offset: 1)
                } label: {
                    Image(systemName: "chevron.down")
                        .foregroundStyle(index == orderedEditorItems.count - 1 ? .gray : .black)
                }
                .disabled(index == orderedEditorItems.count - 1)
            }

            if case .timerSet(let timerSet) = item {
                Button(role: .destructive) {
                    childTimerSets.removeAll { $0.id == timerSet.id }
                } label: {
                    Image(systemName: "trash")
                        .foregroundStyle(.red)
                }
            }
        }
        .padding(.vertical, 12)
        .padding(.horizontal)

        if index < orderedEditorItems.count - 1 {
            HStack {
                Rectangle()
                    .fill(Color.black)
                    .frame(width: 1)
                    .frame(height: 36)
                    .padding(.leading, 45)
                Spacer()
            }
        }
    }

    func formatTime(_ seconds: Int) -> String {
        let hours = seconds / 3600
        let minutes = (seconds % 3600) / 60
        let sec = seconds % 60

        if hours > 0 {
            return "\(hours):\(String(format: "%02d:%02d", minutes, sec))"
        }

        return "\(minutes):\(String(format: "%02d", sec))"
    }

    private func totalDuration(for timerSet: TimerSet) -> Int {
        timerSet.timers.reduce(0) { $0 + $1.time } + timerSet.childTimerSets.reduce(0) { $0 + totalDuration(for: $1) }
    }

    private func syncOrderedItems() {
        let timerItems = timers.map { TimerSetOrderItem(id: $0.id, kind: .timer) }
        let timerSetItems = childTimerSets.map { TimerSetOrderItem(id: $0.id, kind: .timerSet) }
        let validItems = timerItems + timerSetItems
        let validIDs = Set(validItems.map(\.id))

        let keptItems = orderedItems.filter { validIDs.contains($0.id) }
        let keptIDs = Set(keptItems.map(\.id))
        let missingItems = validItems.filter { !keptIDs.contains($0.id) }

        orderedItems = keptItems + missingItems
    }

    private func moveOrderedItem(at index: Int, offset: Int) {
        let destination = index + offset
        guard orderedItems.indices.contains(index), orderedItems.indices.contains(destination) else {
            return
        }

        let item = orderedItems.remove(at: index)
        orderedItems.insert(item, at: destination)
    }

    private func rowLeadingIcon(for item: OrderedEditorItem) -> some View {
        Group {
            switch item {
            case .timer:
                Circle()
                    .stroke(Color.black, lineWidth: 2)
                    .frame(width: 60, height: 60)
            case .timerSet:
                Image(systemName: "square.stack.3d.down.right")
                    .font(.title2)
                    .foregroundStyle(.red)
                    .frame(width: 60, height: 60)
            }
        }
    }

    private func titleText(for item: OrderedEditorItem) -> String {
        switch item {
        case .timer(let timer):
            return timer.name
        case .timerSet(let timerSet):
            return timerSet.name
        }
    }

    private func subtitleText(for item: OrderedEditorItem) -> String {
        switch item {
        case .timer:
            return "タイマー"
        case .timerSet(let timerSet):
            return "タイマーセット ・ 工程数: \(timerSet.totalTimerCount) ・ 合計: \(formatTime(totalDuration(for: timerSet)))"
        }
    }

    private func isEditable(_ item: OrderedEditorItem) -> Bool {
        if case .timer = item {
            return true
        }

        return false
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
                .foregroundStyle(.white)
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
        .appBackground()
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
