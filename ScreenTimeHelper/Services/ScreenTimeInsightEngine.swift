//
//  ScreenTimeInsightEngine.swift
//  ScreenTimeHelper
//
//  Created by Codex on 2026-03-30.
//

import Foundation

enum ScreenTimeInsightEngine {
    static func makeInsights(
        authorizationStatus: ScreenTimeAuthorizationStatus,
        summary: UsageSummary,
        apps: [AppUsage],
        categories: [CategoryUsage]
    ) -> [UsageInsight] {
        var insights: [UsageInsight] = []

        if let topApp = apps.max(by: { $0.usageSeconds < $1.usageSeconds }) {
            insights.append(
                UsageInsight(
                    title: "Most Used App",
                    detail: "\(topApp.name) leads today at \(topApp.usageShareText), making it your strongest attention pull.",
                    systemImage: "crown.fill",
                    tone: topApp.usageSeconds > 7_200 ? .caution : .neutral
                )
            )
        }

        if let topCategory = categories.max(by: { $0.usageSeconds < $1.usageSeconds }) {
            insights.append(
                UsageInsight(
                    title: "Category Driver",
                    detail: "\(topCategory.name) is your biggest bucket at \(topCategory.usageSeconds.formattedAsHoursAndMinutes).",
                    systemImage: "square.grid.2x2.fill",
                    tone: topCategory.name == "Productivity" ? .positive : .neutral
                )
            )
        }

        insights.append(
            UsageInsight(
                title: "Pickup Pattern",
                detail: "You unlocked your phone \(summary.pickupCount) times, averaging \(summary.averageSessionMinutes) minutes per session.",
                systemImage: "hand.tap.fill",
                tone: summary.pickupCount > 80 ? .caution : .neutral
            )
        )

        insights.append(
            UsageInsight(
                title: "Focus Score",
                detail: focusNarrative(for: summary.focusScore),
                systemImage: "scope",
                tone: summary.focusScore >= 75 ? .positive : (summary.focusScore < 50 ? .caution : .neutral)
            )
        )

        if authorizationStatus != .approved {
            insights.insert(
                UsageInsight(
                    title: "Setup Requirement",
                    detail: "Real per-app Screen Time data on iPhone needs Family Controls approval and Apple’s entitlement enabled for this app target.",
                    systemImage: "lock.shield.fill",
                    tone: .caution
                ),
                at: 0
            )
        }

        return insights
    }

    private static func focusNarrative(for score: Int) -> String {
        switch score {
        case 75...:
            "Your usage pattern looks balanced. High-focus stretches are winning over quick-check behavior."
        case 50..<75:
            "Your day is mixed. A few high-frequency apps are interrupting otherwise healthy usage."
        default:
            "Attention is fragmented today. Reducing pickups and social app loops would move this score fastest."
        }
    }
}
