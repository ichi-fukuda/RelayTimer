//
//  TimerListView.swift
//  RelayTimer
//
//  Created by 福田光一郎 on 2026/03/04.
//

import SwiftUI


struct TimerItem: Identifiable, Codable, Hashable {
    var id = UUID()
    var name: String
    var time: Int
}

struct TimerSetOrderItem: Identifiable, Codable, Hashable {
    enum Kind: String, Codable, Hashable {
        case timer
        case timerSet
    }

    var id: UUID
    var kind: Kind
}

struct TimerSet: Identifiable, Codable, Hashable {
    var id = UUID()
    var name: String
    var timers: [TimerItem]
    var childTimerSets: [TimerSet] = []
    var orderedItems: [TimerSetOrderItem] = []

    var resolvedOrderedItems: [TimerSetOrderItem] {
        let timerIDs = Set(timers.map(\.id))
        let timerSetIDs = Set(childTimerSets.map(\.id))
        let filtered = orderedItems.filter { item in
            switch item.kind {
            case .timer:
                return timerIDs.contains(item.id)
            case .timerSet:
                return timerSetIDs.contains(item.id)
            }
        }

        let existingIDs = Set(filtered.map(\.id))
        let missingTimers = timers
            .filter { !existingIDs.contains($0.id) }
            .map { TimerSetOrderItem(id: $0.id, kind: .timer) }
        let missingTimerSets = childTimerSets
            .filter { !existingIDs.contains($0.id) }
            .map { TimerSetOrderItem(id: $0.id, kind: .timerSet) }

        return filtered + missingTimers + missingTimerSets
    }

    var flattenedTimers: [TimerItem] {
        resolvedOrderedItems.flatMap { item in
            switch item.kind {
            case .timer:
                return timers.first(where: { $0.id == item.id }).map { [$0] } ?? []
            case .timerSet:
                return childTimerSets.first(where: { $0.id == item.id })?.flattenedTimers ?? []
            }
        }
    }

    var totalTimerCount: Int {
        flattenedTimers.count
    }

    var nestedSetCount: Int {
        childTimerSets.count
    }
}

struct TimerListView: View {

    @State var timerSets: [TimerSet] = []
    private let storageKey = "savedTimerSets"
    @State private var editMode: EditMode = .inactive
    @State private var selectedTimerSetIDs = Set<TimerSet.ID>()
    @State private var editingTimerSet: TimerSet?

    var body: some View {
        NavigationStack {
            timerList
        }
        .navigationDestination(item: $editingTimerSet) { timerSet in
            addtimer(editingTimerSet: timerSet, timerSets: $timerSets)
        }
        .onAppear {
            loadTimerSets()
        }
        .onChange(of: timerSets) { _, _ in
            saveTimerSets()
        }
    }

    private func saveTimerSets() {
        do {
            let data = try JSONEncoder().encode(timerSets)
            UserDefaults.standard.set(data, forKey: storageKey)
        } catch {
            print("保存エラー: \(error)")
        }
    }

    private func loadTimerSets() {
        guard let data = UserDefaults.standard.data(forKey: storageKey) else { return }

        do {
            timerSets = try JSONDecoder().decode([TimerSet].self, from: data)
        } catch {
            print("読み込みエラー: \(error)")
        }
    }

    private var timerList: some View {
        List(selection: $selectedTimerSetIDs) {
            Section {
                ForEach(timerSets) { timer in
                    TimerRowView(
                        timer: timer,
                        editMode: editMode,
                        onEdit: { editingTimerSet = timer },
                        onDelete: { delete(timer) }
                    )
                }
            } header: {
//                Text("その他")
//                    .font(.footnote)
//                    .foregroundStyle(.white.opacity(0.6))
            }
        }
        .listStyle(.plain)
        .scrollContentBackground(.hidden)
        .background(AppTheme.background)
        .listRowSeparatorTint(.gray)
        .listRowBackground(AppTheme.background)
        .foregroundStyle(.black)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text("タイマーセット一覧")
                    .font(.headline)
                    .foregroundStyle(.white)
            }

            ToolbarItem(placement: .topBarLeading) {
                Button(editMode == .active ? "完了" : "編集") {
                    withAnimation {
                        editMode = editMode == .active ? .inactive : .active
                        if editMode == .inactive {
                            selectedTimerSetIDs.removeAll()
                        }
                    }
                }
                .foregroundStyle(.white)
            }

            ToolbarItem(placement: .topBarTrailing) {
                NavigationLink(destination: addtimer(timerSets: $timerSets)) {
                    Image(systemName: "plus")
                        .font(.system(size: 22, weight: .semibold))
                        .foregroundStyle(.white)
                }
            }

            if editMode == .active {
                ToolbarItem(placement: .bottomBar) {
                    Button("削除") {
                        timerSets.removeAll { timer in
                            selectedTimerSetIDs.contains(timer.id)
                        }
                        selectedTimerSetIDs.removeAll()
                        editMode = .inactive
                    }
                    .disabled(selectedTimerSetIDs.isEmpty)
                }
            }
        }
        .toolbarBackground(AppTheme.accent, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .environment(\.editMode, $editMode)
        .appBackground()
    }

    private func delete(_ timerSet: TimerSet) {
        timerSets.removeAll { $0.id == timerSet.id }
        selectedTimerSetIDs.remove(timerSet.id)
    }
}

struct TimerRowView: View {
    let timer: TimerSet
    let editMode: EditMode
    let onEdit: () -> Void
    let onDelete: () -> Void

    var body: some View {
        HStack(spacing: 12) {
            NavigationLink(destination: TimerView(timerSet: timer)) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(timer.name)
                        .font(.system(size: 50, weight: .thin))
                        .monospacedDigit()
                        .foregroundStyle(.black)

                    HStack(spacing: 10) {
                        Text("工程数: \(timer.totalTimerCount)")

                        if timer.nestedSetCount > 0 {
                            Text("子セット: \(timer.nestedSetCount)")
                        }
                    }
                    .font(.footnote)
                    .foregroundStyle(.black.opacity(0.6))
                }
            }
            .buttonStyle(.plain)

            Spacer()

            if editMode != .active {
                Menu {
                    Button(action: onEdit) {
                        Label("編集", systemImage: "pencil")
                    }
                    .tint(.black)

                    Button(role: .destructive, action: onDelete) {
                        Label("削除", systemImage: "trash")
                    }
                } label: {
                    Image(systemName: "ellipsis")
                        .rotationEffect(.degrees(90))
                        .foregroundStyle(.black)
                        .frame(width: 36, height: 36)
                        .background(Color.white.opacity(0.08))
                        .clipShape(Circle())
                }
            }
        }
        .padding(.vertical, 6)
        .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
    }
}

#Preview {
    TimerListView()
}

private func formatTime(_ seconds: Int) -> String {
    let hours = seconds / 3600
    let minutes = (seconds % 3600) / 60
    let remainingSeconds = seconds % 60

    if hours > 0 {
        return String(format: "%d:%02d:%02d", hours, minutes, remainingSeconds)
    } else {
        return String(format: "%d:%02d", minutes, remainingSeconds)
    }
}
