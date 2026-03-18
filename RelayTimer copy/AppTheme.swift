//
//  AppTheme.swift
//  RelayTimer
//
//  Created by Codex on 2026/03/14.
//

import SwiftUI
import UIKit

enum AppTheme {
    static let background = Color.white
    static let accent = Color.red
}

struct AppThemeModifier: ViewModifier {
    init() {
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor(AppTheme.accent)
        appearance.titleTextAttributes = [.foregroundColor: UIColor.white]
        appearance.largeTitleTextAttributes = [.foregroundColor: UIColor.white]

        let navigationBar = UINavigationBar.appearance()
        navigationBar.standardAppearance = appearance
        navigationBar.scrollEdgeAppearance = appearance
        navigationBar.compactAppearance = appearance
        navigationBar.tintColor = UIColor.white
    }

    func body(content: Content) -> some View {
        content
            .tint(AppTheme.accent)
            .preferredColorScheme(.light)
            .toolbarBackground(AppTheme.accent, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
    }
}

extension View {
    func appTheme() -> some View {
        modifier(AppThemeModifier())
    }

    func appBackground() -> some View {
        background(AppTheme.background.ignoresSafeArea())
    }
}
