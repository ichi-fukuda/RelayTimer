//
//  RelayTimerWidgetBundle.swift
//  RelayTimerWidget
//
//  Created by 福田光一郎 on 2026/03/17.
//

import WidgetKit
import SwiftUI

@main
struct RelayTimerWidgetBundle: WidgetBundle {
    var body: some Widget {
        RelayTimerWidget()
        RelayTimerWidgetControl()
        RelayTimerWidgetLiveActivity()
    }
}
