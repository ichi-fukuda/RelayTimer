//
//  NewTimerSetView.swift
//  RelayTimer
//
//  Created by 福田光一郎 on 2026/03/12.
//

import SwiftUI

struct NewTimerSetView: View {
    let availableTimerSets: [TimerSet]
    @Binding var selectedTimerSets: [TimerSet]

    @Environment(\.dismiss) private var dismiss

    private var selectedIDs: Set<TimerSet.ID> {
        Set(selectedTimerSets.map(\.id))
    }

    var body: some View {
        List {
            if availableTimerSets.isEmpty {
                ContentUnavailableView(
                    "追加できるタイマーセットがありません",
                    systemImage: "square.stack.3d.up.slash",
                    description: Text("先にタイマーセットを作成してください。")
                )
                .listRowBackground(Color.clear)
            } else {
                ForEach(availableTimerSets) { timerSet in
                    Button {
                        toggleSelection(for: timerSet)
                    } label: {
                        HStack(spacing: 12) {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(timerSet.name)
                                    .font(.headline)
                                    .foregroundStyle(.primary)

                                Text("工程数: \(timerSet.totalTimerCount)")
                                    .font(.footnote)
                                    .foregroundStyle(.secondary)
                            }

                            Spacer()

                            Image(systemName: selectedIDs.contains(timerSet.id) ? "checkmark.circle.fill" : "circle")
                                .foregroundStyle(selectedIDs.contains(timerSet.id) ? AppTheme.accent : .secondary)
                        }
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .navigationTitle("タイマーセットを追加")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(AppTheme.accent, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("完了") {
                    dismiss()
                }
                .foregroundStyle(.white)
            }
        }
        .appBackground()
    }

    private func toggleSelection(for timerSet: TimerSet) {
        if let index = selectedTimerSets.firstIndex(where: { $0.id == timerSet.id }) {
            selectedTimerSets.remove(at: index)
        } else {
            selectedTimerSets.append(timerSet)
        }
    }
}

#Preview {
    NavigationStack {
        NewTimerSetView(
            availableTimerSets: [
                TimerSet(
                    name: "洗面",
                    timers: [
                        TimerItem(name: "歯磨き", time: 180),
                        TimerItem(name: "洗顔", time: 120)
                    ]
                )
            ],
            selectedTimerSets: .constant([])
        )
    }
}
