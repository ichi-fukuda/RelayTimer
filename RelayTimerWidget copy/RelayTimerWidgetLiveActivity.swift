//
//  RelayTimerWidgetLiveActivity.swift
//  RelayTimerWidget
//
//  Created by 福田光一郎 on 2026/03/17.
//

import ActivityKit
import WidgetKit
import SwiftUI

struct RelayTimerWidgetLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: TimerLiveActivityAttributes.self) { context in
            VStack(alignment: .leading, spacing: 8) {
                Text(context.attributes.timerSetName)
                    .font(.headline)
                    .foregroundStyle(.white)

                Text(context.state.stepName)
                    .font(.subheadline)
                    .foregroundStyle(.white.opacity(0.9))

                Text(context.state.endDate, style: .timer)
                    .font(.system(size: 32, weight: .semibold, design: .rounded))
                    .foregroundStyle(.white)
            }
            .padding()
            .activityBackgroundTint(Color.red)
            .activitySystemActionForegroundColor(Color.white)

        } dynamicIsland: { context in
            DynamicIsland {
                DynamicIslandExpandedRegion(.leading) {
                    Text(context.state.stepName)
                        .foregroundStyle(.white)
                }
                DynamicIslandExpandedRegion(.trailing) {
                    Text(context.state.endDate, style: .timer)
                        .foregroundStyle(.white)
                }
                DynamicIslandExpandedRegion(.bottom) {
                    Text(context.attributes.timerSetName)
                        .font(.caption)
                        .foregroundStyle(.white.opacity(0.9))
                }
            } compactLeading: {
                Text("⏱")
            } compactTrailing: {
                Text(context.state.endDate, style: .timer)
            } minimal: {
                Text("⏱")
            }
            .keylineTint(Color.red)
        }
    }
}

extension TimerLiveActivityAttributes {
    fileprivate static var preview: TimerLiveActivityAttributes {
        TimerLiveActivityAttributes(timerSetName: "サンプル", totalSeconds: 600)
    }
}

extension TimerLiveActivityAttributes.ContentState {
    fileprivate static var running: TimerLiveActivityAttributes.ContentState {
        TimerLiveActivityAttributes.ContentState(
            stepName: "調理",
            endDate: Date().addingTimeInterval(600),
            isRunning: true
        )
    }
}

#Preview("Notification", as: .content, using: TimerLiveActivityAttributes.preview) {
    RelayTimerWidgetLiveActivity()
} contentStates: {
    TimerLiveActivityAttributes.ContentState.running
}
