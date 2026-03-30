//
//  FamilyControlsScreenTimeService.swift
//  ScreenTimeHelper
//
//  Created by Codex on 2026-03-30.
//

import Foundation

#if canImport(FamilyControls)
import FamilyControls

@available(iOS 16.0, *)
struct FamilyControlsScreenTimeService: ScreenTimeServicing {
    private let authorizationCenter = AuthorizationCenter.shared

    func fetchSnapshot() async -> ScreenTimeSnapshot {
        let status = currentStatus()
        let fallback = PreviewScreenTimeService(
            authorizationStatus: status == .approved ? .approved : status
        )
        return await fallback.fetchSnapshot()
    }

    func requestAuthorization() async -> ScreenTimeAuthorizationStatus {
        do {
            try await authorizationCenter.requestAuthorization(for: .individual)
            return .approved
        } catch {
            return .denied
        }
    }

    private func currentStatus() -> ScreenTimeAuthorizationStatus {
        switch authorizationCenter.authorizationStatus {
        case .approved:
            .approved
        case .denied:
            .denied
        case .notDetermined:
            .unknown
        @unknown default:
            .unknown
        }
    }
}
#endif
