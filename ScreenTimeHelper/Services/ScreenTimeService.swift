//
//  ScreenTimeService.swift
//  ScreenTimeHelper
//
//  Created by Codex on 2026-03-30.
//

import Foundation

protocol ScreenTimeServicing {
    func fetchSnapshot() async -> ScreenTimeSnapshot
    func requestAuthorization() async -> ScreenTimeAuthorizationStatus
}

enum ScreenTimeServiceFactory {
    static func makeService() -> ScreenTimeServicing {
        #if canImport(FamilyControls)
        if #available(iOS 16.0, *) {
            return FamilyControlsScreenTimeService()
        }
        #endif

        return PreviewScreenTimeService(
            authorizationStatus: .unavailable
        )
    }
}
