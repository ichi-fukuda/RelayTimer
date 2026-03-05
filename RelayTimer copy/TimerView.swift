//
//  TimerView.swift
//  RelayTimer
//
//  Created by 福田光一郎 on 2026/03/04.
//

import SwiftUI

struct TimerView: View {
    @State var settime: Int = 200
    @State var time: Int = 0
    @State var timer: Timer!
    @State var isRunning = false
    var progress: Double {
        Double(time) / Double(settime)
    }
    
    @State var ButtonString: String = "START"
    
    var body: some View {
        Spacer(minLength: 20)
        HStack(spacing: 80){
            Circle()
                .stroke(.gray, lineWidth: 5)
                .frame(width: 50, height: 50)
            Circle()
                .stroke(.gray, lineWidth: 5)
                .frame(width: 50, height: 50)
            Circle()
                .stroke(.gray, lineWidth: 5)
                .frame(width: 50, height: 50)
        }
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
                    if !isRunning {
                        ButtonString = "DONE"
                        start()
                    } else {
                        ButtonString = "START"
                        stop()
                    }
                } label: {
                    Text(ButtonString)
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
            Button{
                if !isRunning {
                    ButtonString = "DONE"
                    restart()
                } else {
                    ButtonString = "START"
                    stop()
                }
            }label:{
                Image(systemName: isRunning ? "stop.circle.fill" : "play.circle.fill")
                    .foregroundStyle(.red)
                .frame(width: 100, height: 100)
                .font(.system(size: 70))
            }
            Spacer()
        }
        .navigationTitle("朝の支度")
        .navigationBarTitleDisplayMode(.inline)
}
    func start() {
        time = settime
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            if time > 0 {
                time -= 1
            }else{
                stop()
            }
        }
        isRunning = true
    }
    func stop() {
        timer.invalidate()
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
}

#Preview {
    NavigationStack {
        TimerView()
    }
}
