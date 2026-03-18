//
//  TimerView.swift
//  RelayTimer
//
//  Created by 福田光一郎 on 2026/03/04.
//

import SwiftUI

struct TimerView: View {
    @Environment(\.scenePhase) private var scenePhase
    @State private var currentIndex = 0
    @State private var showFinish = false
    @State private var time: Int = 0
    @State private var timer: Timer?
    @State private var isRunning = false
    @State private var isOvertime = false
    @State private var endDate: Date?
    @State private var startedAt: Date?
    @State private var elapsedSeconds: Int = 0
    @State private var stepStartedAt: Date?
    @State private var stepDurations: [Int]
    @State private var stepOverruns: [Bool]

    var timerSet: TimerSet

    private var allTimers: [TimerItem] {
        timerSet.flattenedTimers
    }

    private var currentTimer: TimerItem? {
        guard allTimers.indices.contains(currentIndex) else { return nil }
        return allTimers[currentIndex]
    }

    var settime: Int {
        currentTimer?.time ?? 0
    }

    var progress: Double {
        guard settime > 0 else { return 0 }
        return Double(time) / Double(settime)
    }

    private var displayTimeText: String {
        let absTime = abs(time)
        let minutes = absTime / 60
        let seconds = absTime % 60

        if isOvertime {
            return "+\(minutes):\(String(format: "%02d", seconds))"
        } else {
            return "\(minutes):\(String(format: "%02d", seconds))"
        }
    }

    init(timerSet: TimerSet) {
        self.timerSet = timerSet

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

        _stepDurations = State(initialValue: Array(repeating: 0, count: timerSet.flattenedTimers.count))
        _stepOverruns = State(initialValue: Array(repeating: false, count: timerSet.flattenedTimers.count))
    }

    var body: some View {
        VStack {
            Spacer(minLength: 20)

            HStack(alignment: .top, spacing: 24) {
                ForEach(0..<allTimers.count, id: \.self) { index in
                    VStack(spacing: 8) {
                        Circle()
                            .fill(index == currentIndex ? .red : .gray.opacity(0.3))
                            .frame(width: 20, height: 20)

                        Text(allTimers.indices.contains(index) ? allTimers[index].name : "")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundStyle(index == currentIndex ? .primary : .secondary)
                            .lineLimit(1)
                            .minimumScaleFactor(0.7)
                    }
                    .frame(maxWidth: .infinity)
                }
            }
            .padding(.horizontal)

            Spacer(minLength: 50)

            ZStack {
                Circle()
                    .stroke(.gray.opacity(0.3), lineWidth: 10)
                    .frame(width: 350, height: 350)

                Circle()
                    .trim(from: 0.0, to: progress)
                    .stroke(.red, style: StrokeStyle(lineWidth: 10, lineCap: .round))
                    .frame(width: 350, height: 350)
                    .rotationEffect(.degrees(-90))
                    .shadow(color: Color.black.opacity(0.3), radius: 2, x: 0, y: 5)

                VStack(spacing: 12) {
                    Text(displayTimeText)
                        .font(.system(size: 100, weight: .thin))
                        .monospacedDigit()
                        .foregroundStyle(isOvertime ? .red : .primary)

                    Text(currentTimer?.name ?? "")
                        .font(.title3)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                        .minimumScaleFactor(0.8)
                        .padding(.horizontal, 24)
                }
            }
            Spacer()

            VStack {
                Button {
                    if isRunning {
                        nextStep()
                    } else {
                        start()
                    }
                } label: {
                    Text(isRunning ? "DONE" : "START")
                        .foregroundStyle(.black)
                        .font(.largeTitle)
                        .frame(width: 150, height: 100)
                        .padding()
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color.black, lineWidth: 2)
                        )
                }
            }

            HStack {
//                Button {
//                    if !isRunning {
//                        start()
//                    } else {
//                        stop()
//                    }
//                } label: {
//                    Image(systemName: isRunning ? "stop.circle.fill" : "play.circle.fill")
//                        .foregroundStyle(.red)
//                        .frame(width: 100, height: 100)
//                        .font(.system(size: 70))
//                }

                Spacer()
            }
        }
        .navigationTitle(timerSet.name)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text(timerSet.name)
                    .font(.headline)
                    .foregroundStyle(.white)
            }
        }
        .toolbarBackground(Color.red, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .tint(.white)
        .background(
            NavigationLink(
                destination: FinishView(
                    elapsedSeconds: elapsedSeconds,
                    stepNames: allTimers.map(\.name),
                    stepDurations: stepDurations,
                    stepOverruns: stepOverruns
                ),
                isActive: $showFinish,
                label: { EmptyView() }
            )
            .hidden()
        )
        .onChange(of: scenePhase) { _, newPhase in
            if newPhase == .active {
                refreshTimeFromEndDate()
                if isRunning {
                    scheduleTimer()
                }
            } else {
                timer?.invalidate()
            }
        }
        .onDisappear {
            timer?.invalidate()
        }
        .appBackground()
    }

    func start() {
        guard let currentTimer else { return }
        timer?.invalidate()
        time = settime
        isOvertime = false
        stepStartedAt = Date()
        if startedAt == nil {
            startedAt = Date()
        }
        endDate = Date().addingTimeInterval(TimeInterval(settime))
        scheduleTimer()
        isRunning = true

        if #available(iOS 16.1, *) {
            LiveActivityManager.shared.startIfNeeded(
                timerSetName: timerSet.name,
                stepName: currentTimer.name,
                endDate: endDate ?? Date(),
                totalSeconds: settime
            )
        }
    }

    func stop() {
        timer?.invalidate()
        isRunning = false

        if #available(iOS 16.1, *) {
            LiveActivityManager.shared.update(
                stepName: currentTimer?.name ?? "",
                endDate: endDate ?? Date(),
                isRunning: false
            )
        }
    }

    func nextStep() {
        guard !allTimers.isEmpty else {
            isRunning = false
            return
        }
        timer?.invalidate()
        if let stepStartedAt {
            let duration = max(0, Int(Date().timeIntervalSince(stepStartedAt)))
            if stepDurations.indices.contains(currentIndex) {
                stepDurations[currentIndex] = duration
                stepOverruns[currentIndex] = isOvertime
            }
        }

        if currentIndex < allTimers.count - 1 {
            currentIndex += 1
            isOvertime = false
            start()
        } else {
            isRunning = false
            if let startedAt {
                elapsedSeconds = max(0, Int(Date().timeIntervalSince(startedAt)))
            } else {
                elapsedSeconds = 0
            }
            if #available(iOS 16.1, *) {
                LiveActivityManager.shared.end()
            }
            showFinish = true
        }
    }

    private func scheduleTimer() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            refreshTimeFromEndDate()
        }
    }

    private func refreshTimeFromEndDate() {
        guard let endDate else { return }
        let remaining = Int(endDate.timeIntervalSinceNow.rounded(.down))
        if remaining >= 0 {
            time = remaining
            isOvertime = false
        } else {
            time = remaining
            isOvertime = true
        }
    }
}

#Preview {
    NavigationStack {
        TimerView(
            timerSet: TimerSet(
                name: "サンプル",
                timers: [
                    TimerItem(name: "調理", time: 3),
                    TimerItem(name: "食事", time: 600),
                    TimerItem(name: "洗い物", time: 180)
                ]
            )
        )
    }
}
