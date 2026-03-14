//
//  TimerView.swift
//  RelayTimer
//
//  Created by 福田光一郎 on 2026/03/04.
//

import SwiftUI

struct TimerView: View {
    var settime: Int {
        timerSet.timers[currentIndex].time
    }
    @State var time: Int = 0
    @State var timer: Timer?
    @State var isRunning = false
    
    @State private var currentIndex = 0
    
    var timerSet: TimerSet
    
    var progress: Double {
        Double(time) / Double(settime)
    }
    
//    @State var ButtonString: String = "START"
    
    var body: some View {
        Spacer(minLength: 20)
        HStack(alignment: .top, spacing: 24) {
            ForEach(0..<timerSet.timers.count, id: \.self) { index in
                VStack(spacing: 8) {
                    Circle()
                        .fill(index == currentIndex ? .red : .gray.opacity(0.3))
                        .frame(width: 20, height: 20)
                    
                    Text(timerSet.timers[index].name)
                        .font(.headline)
                        .font(.system(size: 16))
                }
                .frame(maxWidth: .infinity)
            }
        }
        .padding(.horizontal)
        Spacer(minLength: 50)
        ZStack{
            Circle()
                .stroke(.gray.opacity(0.3), lineWidth: 10)
                .frame(width: 350, height: 350)
            Circle()
                .trim(from: 0.0, to: progress)
                .stroke(.red, style:StrokeStyle(lineWidth: 10, lineCap: .round))
                .frame(width: 350, height: 350)
                .rotationEffect(.degrees(-90))
//                .blur(radius:3)
                .shadow(color: Color.black.opacity(0.3), radius: 2, x: 0, y: 5)
            
            Text(String(format: "%d:%02d", time / 60, time % 60))
                .font(.system(size: 100, weight: .thin))
                .monospacedDigit()
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
        HStack{
            Button {
                if !isRunning {
                    start()        // ←ここ
                } else {
                    stop()     // DONEで次へ
                }
            }label:{
                Image(systemName: isRunning ? "stop.circle.fill" : "play.circle.fill")
                    .foregroundStyle(.red)
                .frame(width: 100, height: 100)
                .font(.system(size: 70))
            }
            Spacer()
        }
        .navigationTitle(timerSet.name)
        .navigationBarTitleDisplayMode(.inline)
}
    func start() {
        time = settime
        
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            if time > 0 {
                time -= 1
            } else {
                nextStep()
            }
        }
        
        isRunning = true
    }
    func stop() {
        timer?.invalidate()
        isRunning = false
    }
    func restart(){
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            if time > 0 {
                time -= 1
            }else{
                stop()
            }
        }
        isRunning = true
    }
    
    func nextStep() {
        timer?.invalidate()
        
        if currentIndex < timerSet.timers.count - 1 {
            currentIndex += 1
            start()
        } else {
            isRunning = false
        }
    }
}

#Preview {
    NavigationStack {
        TimerView(
            timerSet: TimerSet(
                name: "サンプル",
                timers: [
                    TimerItem(name: "調理", time: 300),
                    TimerItem(name: "食事", time: 600),
                    TimerItem(name: "洗い物", time: 180)
                ]
            )
        )
    }
}
