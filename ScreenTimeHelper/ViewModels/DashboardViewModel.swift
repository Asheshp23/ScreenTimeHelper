//
//  DashboardViewModel.swift
//  ScreenTimeHelper
//
//  Created by Codex on 2026-03-30.
//

import Foundation
import Combine

@MainActor
final class DashboardViewModel: ObservableObject {
    private let service: ScreenTimeServicing

    @Published var snapshot: ScreenTimeSnapshot?
    @Published var isLoading = false
    @Published var errorMessage: String?

    init(service: ScreenTimeServicing) {
        self.service = service
    }

    func load() async {
        isLoading = true
        errorMessage = nil
        snapshot = await service.fetchSnapshot()
        isLoading = false
    }

    func requestAuthorization() async {
        isLoading = true
        let status = await service.requestAuthorization()
        let refreshedSnapshot = await service.fetchSnapshot()
        snapshot = refreshedSnapshot.updatingAuthorization(to: status)
        isLoading = false
    }
}

private extension ScreenTimeSnapshot {
    func updatingAuthorization(to status: ScreenTimeAuthorizationStatus) -> ScreenTimeSnapshot {
        ScreenTimeSnapshot(
            generatedAt: generatedAt,
            intervalLabel: intervalLabel,
            authorizationStatus: status,
            summary: summary,
            appUsage: appUsage,
            categoryUsage: categoryUsage,
            insights: ScreenTimeInsightEngine.makeInsights(
                authorizationStatus: status,
                summary: summary,
                apps: appUsage,
                categories: categoryUsage
            )
        )
    }
}
