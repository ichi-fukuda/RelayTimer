//
//  NewTimerView.swift
//  RelayTimer
//
//  Created by 福田光一郎 on 2026/03/12.
//

import SwiftUI

struct NewTimerView: View {

    @Binding var timers: [TimerItem]

    @State private var name = ""
    
    @State private var hours = 0
    @State private var minutes = 0
    @State private var seconds = 0
    @State private var showTimePicker = false

    @Environment(\.dismiss) var dismiss

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

                    TextField("タイマー名を入力", text: $name)
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
        .navigationTitle("新規タイマー")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(AppTheme.accent, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("保存") {
                    let newTimer = TimerItem(
                        name: name,
                        time: totalSeconds
                    )

                    timers.append(newTimer)
                    dismiss()
                }
                .disabled(name.isEmpty || totalSeconds == 0)
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
        .appBackground()
    }
}

#Preview {
    NavigationStack {
        NewTimerView(timers: .constant([]))
    }
}
