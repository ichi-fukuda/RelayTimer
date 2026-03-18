//
//  LiveActivityModels.swift
//  RelayTimer
//
//  Created by Codex on 2026/03/14.
//

import Foundation
import ActivityKit

struct TimerLiveActivityAttributes: ActivityAttributes {
    struct ContentState: Codable, Hashable {
        var stepName: String
        var endDate: Date
        var isRunning: Bool
    }

    var timerSetName: String
    var totalSeconds: Int
}
