//
//  PreviewScreenTimeService.swift
//  ScreenTimeHelper
//
//  Created by Codex on 2026-03-30.
//

import Foundation

struct PreviewScreenTimeService: ScreenTimeServicing {
    let authorizationStatus: ScreenTimeAuthorizationStatus

    func fetchSnapshot() async -> ScreenTimeSnapshot {
        let appUsage = [
            AppUsage(name: "Instagram", category: "Social", usageSeconds: 8_400, sessions: 19, trend: .up),
            AppUsage(name: "Safari", category: "Productivity", usageSeconds: 5_700, sessions: 13, trend: .flat),
            AppUsage(name: "YouTube", category: "Entertainment", usageSeconds: 4_980, sessions: 11, trend: .up),
            AppUsage(name: "Messages", category: "Communication", usageSeconds: 3_900, sessions: 28, trend: .down),
            AppUsage(name: "Slack", category: "Work", usageSeconds: 2_520, sessions: 16, trend: .flat)
        ]

        let categories = [
            CategoryUsage(name: "Social", usageSeconds: 10_200, colorHex: "#E55D5D"),
            CategoryUsage(name: "Productivity", usageSeconds: 6_600, colorHex: "#4A9D7C"),
            CategoryUsage(name: "Entertainment", usageSeconds: 5_460, colorHex: "#E6A23C"),
            CategoryUsage(name: "Communication", usageSeconds: 4_020, colorHex: "#5C88DA")
        ]

        let summary = UsageSummary(
            totalUsageSeconds: appUsage.reduce(0) { $0 + $1.usageSeconds },
            averageSessionMinutes: 9,
            pickupCount: 72,
            focusScore: 61
        )

        return ScreenTimeSnapshot(
            generatedAt: .now,
            intervalLabel: "Today",
            authorizationStatus: authorizationStatus,
            summary: summary,
            appUsage: appUsage,
            categoryUsage: categories,
            insights: ScreenTimeInsightEngine.makeInsights(
                authorizationStatus: authorizationStatus,
                summary: summary,
                apps: appUsage,
                categories: categories
            )
        )
    }

    func requestAuthorization() async -> ScreenTimeAuthorizationStatus {
        authorizationStatus == .unavailable ? .unavailable : .approved
    }
}
