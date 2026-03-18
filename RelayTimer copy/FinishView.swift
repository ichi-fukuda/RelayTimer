//
//  FinishView.swift
//  RelayTimer
//
//  Created by 福田光一郎 on 2026/03/14.
//

import SwiftUI

struct FinishView: View {
    let elapsedSeconds: Int
    let stepNames: [String]
    let stepDurations: [Int]
    let stepOverruns: [Bool]

    private var elapsedText: String {
        let hours = elapsedSeconds / 3600
        let minutes = (elapsedSeconds % 3600) / 60
        let seconds = elapsedSeconds % 60

        if hours > 0 {
            return String(format: "%d:%02d:%02d", hours, minutes, seconds)
        } else {
            return String(format: "%d:%02d", minutes, seconds)
        }
    }

    var body: some View {
        NavigationStack {  // NavigationStackでラップする
            VStack(spacing: 16) {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundStyle(.red)
                    .frame(width: 100, height: 100)
                    .font(.system(size: 70))

                Text("DONE")
                    .font(.system(size: 70))
                    .padding(.bottom,20)

                VStack(spacing: 6) {
                    Text("かかった時間")
                        .font(.footnote)
                        .foregroundStyle(.black.opacity(0.6))

                    Text(elapsedText)
                        .font(.system(size: 40, weight: .semibold))
                        .monospacedDigit()
                        .foregroundStyle(.black)
                }
                .padding(.top, 8)

                if !stepNames.isEmpty {
                    VStack(alignment: .leading, spacing: 10) {
                        Text("工程ごとの時間")
                            .font(.footnote)
                            .foregroundStyle(.black.opacity(0.6))

                        ForEach(Array(stepNames.enumerated()), id: \.offset) { index, name in
                            HStack {
                                Text(name)
                                    .font(.body)
                                    .foregroundStyle(.black)
                                    .lineLimit(1)

                                Spacer()

                                let duration = stepDurations[safe: index] ?? 0
                                let isOverrun = stepOverruns[safe: index] ?? false
                                Text(formatDuration(duration))
                                    .font(.body.monospacedDigit())
                                    .foregroundStyle(isOverrun ? .red : .black)
                            }
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 24)
                }

                // 「閉じる」をタップすると TimerListView へ遷移
                NavigationLink(destination: TimerListView()) {
                    Text("閉じる")
                }
                .buttonStyle(.borderedProminent)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .appBackground()
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(AppTheme.accent, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .navigationBarBackButtonHidden(true) // 戻るボタンを非表示
        }
    }
}

#Preview {
    FinishView(
        elapsedSeconds: 385,
        stepNames: ["調理", "食事", "片付け"],
        stepDurations: [120, 600, 180],
        stepOverruns: [false, true, false]
    )
}
private func formatDuration(_ seconds: Int) -> String {
    let hours = seconds / 3600
    let minutes = (seconds % 3600) / 60
    let remainingSeconds = seconds % 60

    if hours > 0 {
        return String(format: "%d:%02d:%02d", hours, minutes, remainingSeconds)
    } else {
        return String(format: "%d:%02d", minutes, remainingSeconds)
    }
}

private extension Array {
    subscript(safe index: Int) -> Element? {
        guard indices.contains(index) else { return nil }
        return self[index]
    }
}

