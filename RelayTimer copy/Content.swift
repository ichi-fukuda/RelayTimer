//
//  Content.swift
//  RelayTimer
//
//  Created by 福田光一郎 on 2026/03/05.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        NavigationStack {
            TimerListView()
        }
        .toolbarBackground(AppTheme.accent, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .appBackground()
    }
}
