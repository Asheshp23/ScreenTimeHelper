//
//  AppModel.swift
//  ScreenTimeHelper
//
//  Created by Codex on 2026-03-30.
//

import Foundation
import Combine

final class AppModel: ObservableObject {
    let dashboardViewModel = DashboardViewModel(
        service: ScreenTimeServiceFactory.makeService()
    )
}
