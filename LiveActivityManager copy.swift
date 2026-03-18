//
//  LiveActivityManager.swift
//  RelayTimer
//
//  Created by Codex on 2026/03/14.
//

import Foundation
import ActivityKit

@MainActor
final class LiveActivityManager {
    static let shared = LiveActivityManager()

    private var activity: Activity<TimerLiveActivityAttributes>?

    func startIfNeeded(timerSetName: String, stepName: String, endDate: Date, totalSeconds: Int) {
        guard activity == nil else {
            update(stepName: stepName, endDate: endDate, isRunning: true)
            return
        }
        let authorizationInfo = ActivityAuthorizationInfo()
        guard authorizationInfo.areActivitiesEnabled else {
            print("Live Activity disabled: areActivitiesEnabled=false")
            return
        }

        let attributes = TimerLiveActivityAttributes(
            timerSetName: timerSetName,
            totalSeconds: totalSeconds
        )
        let state = TimerLiveActivityAttributes.ContentState(
            stepName: stepName,
            endDate: endDate,
            isRunning: true
        )

        do {
            if #available(iOS 16.2, *) {
                let content = ActivityContent(
                    state: state,
                    staleDate: endDate.addingTimeInterval(3600)
                )
                activity = try Activity.request(
                    attributes: attributes,
                    content: content,
                    pushType: nil
                )
            } else {
                activity = try Activity.request(
                    attributes: attributes,
                    contentState: state,
                    pushType: nil
                )
            }
            if let activity {
                print("Live Activity started: \(activity.id)")
            }
        } catch {
            print("Live Activity start error: \(error)")
        }
    }

    func update(stepName: String, endDate: Date, isRunning: Bool) {
        guard let activity else { return }

        let state = TimerLiveActivityAttributes.ContentState(
            stepName: stepName,
            endDate: endDate,
            isRunning: isRunning
        )

        Task {
            if #available(iOS 16.2, *) {
                let content = ActivityContent(
                    state: state,
                    staleDate: endDate.addingTimeInterval(3600)
                )
                await activity.update(content)
            } else {
                await activity.update(using: state)
            }
        }
    }

    func end() {
        guard let activity else { return }
        Task {
            if #available(iOS 16.2, *) {
                await activity.end(nil, dismissalPolicy: .immediate)
            } else {
                await activity.end(dismissalPolicy: .immediate)
            }
        }
        self.activity = nil
    }
}
