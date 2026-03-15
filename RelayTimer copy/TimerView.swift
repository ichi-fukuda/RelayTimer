//
//  TimerView.swift
//  RelayTimer
//
//  Created by 福田光一郎 on 2026/03/04.
//

import SwiftUI

struct TimerView: View {
    @State private var currentIndex = 0
    @State private var showFinish = false
    @State private var time: Int = 0
    @State private var timer: Timer?
    @State private var isRunning = false
    @State private var isOvertime = false
    

    var timerSet: TimerSet

    private var currentTimer: TimerItem? {
        guard timerSet.timers.indices.contains(currentIndex) else { return nil }
        return timerSet.timers[currentIndex]
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

    var body: some View {
        VStack {
            Spacer(minLength: 20)

            HStack(alignment: .top, spacing: 24) {
                ForEach(0..<timerSet.timers.count, id: \.self) { index in
                    VStack(spacing: 8) {
                        Circle()
                            .fill(index == currentIndex ? .red : .gray.opacity(0.3))
                            .frame(width: 20, height: 20)

                        Text(timerSet.timers.indices.contains(index) ? timerSet.timers[index].name : "")
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

                Text(displayTimeText)
                    .font(.system(size: 100, weight: .thin))
                    .monospacedDigit()
                    .foregroundStyle(isOvertime==true ? .red : .black)
            }

            VStack {
                Button {
                    if isRunning {
                        nextStep()
                    } else {
                        start()
                    }
                } label: {
                    Text(isRunning ? "DONE" : "START")
                        .foregroundStyle(Color.black)
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
                Button {
                    if !isRunning {
                        start()
                    } else {
                        stop()
                    }
                } label: {
                    Image(systemName: isRunning ? "stop.circle.fill" : "play.circle.fill")
                        .foregroundStyle(.red)
                        .frame(width: 100, height: 100)
                        .font(.system(size: 70))
                }

                Spacer()
            }
        }
        .navigationTitle(timerSet.name)
        .navigationBarTitleDisplayMode(.inline)
        .background(
            NavigationLink(
                destination: FinishView(),
                isActive: $showFinish,
                label: { EmptyView() }
            )
            .hidden()
        )
        .onDisappear {
            timer?.invalidate()
        }
    }

    func start() {
        guard currentTimer != nil else { return }
        timer?.invalidate()
        time = settime

        isOvertime = false

        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            if time > 0 {
                time -= 1
            } else {
                isOvertime = true
                time -= 1
            }
        }

        isRunning = true
    }

    func stop() {
        timer?.invalidate()
        isRunning = false
    }

    func nextStep() {
        guard !timerSet.timers.isEmpty else {
            isRunning = false
            return
        }
        timer?.invalidate()

        if currentIndex < timerSet.timers.count - 1 {
            currentIndex += 1
            isOvertime = false
            start()
        } else {
            isRunning = false
            showFinish = true
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
