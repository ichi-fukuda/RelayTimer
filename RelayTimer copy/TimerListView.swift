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

struct TimerSet: Identifiable, Codable, Hashable {
    var id = UUID()
    var name: String
    var timers: [TimerItem]
}

struct TimerListView: View {
    
    @State var timerSets: [TimerSet] = []
    private let storageKey = "savedTimerSets"
    @State private var searchText = ""
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
        .onChange(of: timerSets) { _ in
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
        List(timerSets, selection: $selectedTimerSetIDs) { timer in
            TimerRowView(
                timer: timer,
                editMode: editMode,
                timerSets: $timerSets,
                editingTimerSet: $editingTimerSet
            )
        }
        .searchable(text: $searchText, placement: .navigationBarDrawer(displayMode: .always))
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text("タイマーセット一覧")
                    .font(.headline)
            }

            ToolbarItem(placement: .topBarTrailing) {
                Button(editMode == .active ? "完了" : "編集") {
                    withAnimation {
                        editMode = editMode == .active ? .inactive : .active
                        if editMode == .inactive {
                            selectedTimerSetIDs.removeAll()
                        }
                    }
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
        .environment(\.editMode, $editMode)
        .overlay(alignment: .bottomTrailing) {
            if editMode != .active {
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

struct TimerRowView: View {
    let timer: TimerSet
    let editMode: EditMode
    @Binding var timerSets: [TimerSet]
    @Binding var editingTimerSet: TimerSet?

    var body: some View {
        HStack(spacing: 16) {
            VStack(alignment: .leading, spacing: 8) {
                Text(timer.name)
                    .font(.system(size: 28, weight: .semibold))
                    .foregroundStyle(.primary)

                Text("工程数: \(timer.timers.count)")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            .allowsHitTesting(false)

            Spacer()

            if editMode != .active {
                NavigationLink(destination: TimerView(timerSet: timer)) {
                    Image(systemName: "play.fill")
                        .foregroundStyle(.white)
                        .frame(width: 56, height: 56)
                        .background(.pink)
                        .clipShape(Circle())
                }
                .contentShape(Circle())

                Menu {
                    Button {
                        editingTimerSet = timer
                    } label: {
                        Label("編集", systemImage: "pencil")
                    }

                    Button(role: .destructive) {
                        timerSets.removeAll { $0.id == timer.id }
                    } label: {
                        Label("削除", systemImage: "trash")
                    }

                } label: {
                    Image(systemName: "ellipsis")
                        .rotationEffect(.degrees(90))
                        .foregroundStyle(.primary)
                        .frame(width: 44, height: 44)
                        .background(Color(.secondarySystemBackground))
                        .clipShape(Circle())
                }
            }
        }
        .padding(.vertical, 12)
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
