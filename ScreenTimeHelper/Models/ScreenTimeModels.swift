//
//  ScreenTimeModels.swift
//  ScreenTimeHelper
//
//  Created by Codex on 2026-03-30.
//

import Foundation

struct ScreenTimeSnapshot: Identifiable, Equatable {
    let id = UUID()
    let generatedAt: Date
    let intervalLabel: String
    let authorizationStatus: ScreenTimeAuthorizationStatus
    let summary: UsageSummary
    let appUsage: [AppUsage]
    let categoryUsage: [CategoryUsage]
    let insights: [UsageInsight]
}

struct UsageSummary: Equatable {
    let totalUsageSeconds: TimeInterval
    let averageSessionMinutes: Int
    let pickupCount: Int
    let focusScore: Int
}

struct AppUsage: Identifiable, Equatable {
    let id = UUID()
    let name: String
    let category: String
    let usageSeconds: TimeInterval
    let sessions: Int
    let trend: UsageTrend

    var usageShareText: String {
        usageSeconds.formattedAsHoursAndMinutes
    }
}

struct CategoryUsage: Identifiable, Equatable {
    let id = UUID()
    let name: String
    let usageSeconds: TimeInterval
    let colorHex: String
}

struct UsageInsight: Identifiable, Equatable {
    let id = UUID()
    let title: String
    let detail: String
    let systemImage: String
    let tone: InsightTone
}

enum ScreenTimeAuthorizationStatus: String, Equatable {
    case unknown
    case approved
    case denied
    case unavailable

    var title: String {
        switch self {
        case .unknown:
            "Needs Setup"
        case .approved:
            "Connected"
        case .denied:
            "Permission Needed"
        case .unavailable:
            "Capability Missing"
        }
    }

    var detail: String {
        switch self {
        case .unknown:
            "Request Family Controls access to unlock Screen Time insights."
        case .approved:
            "Screen Time access is available for reporting."
        case .denied:
            "This device has not granted the required Screen Time authorization."
        case .unavailable:
            "Family Controls entitlement or supported OS features are not configured yet."
        }
    }
}

enum UsageTrend: String, Equatable {
    case up
    case down
    case flat

    var symbol: String {
        switch self {
        case .up:
            "arrow.up.right"
        case .down:
            "arrow.down.right"
        case .flat:
            "arrow.right"
        }
    }

    var description: String {
        switch self {
        case .up:
            "Up"
        case .down:
            "Down"
        case .flat:
            "Steady"
        }
    }
}

enum InsightTone: Equatable {
    case positive
    case neutral
    case caution
}

extension TimeInterval {
    var formattedAsHoursAndMinutes: String {
        let totalMinutes = Int(self / 60)
        let hours = totalMinutes / 60
        let minutes = totalMinutes % 60

        if hours == 0 {
            return "\(minutes)m"
        }

        if minutes == 0 {
            return "\(hours)h"
        }

        return "\(hours)h \(minutes)m"
    }
}
