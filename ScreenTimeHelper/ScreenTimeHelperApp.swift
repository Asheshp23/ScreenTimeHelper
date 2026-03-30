//
//  ScreenTimeHelperApp.swift
//  ScreenTimeHelper
//
//  Created by Ashesh Patel on 2026-03-30.
//

import SwiftUI

@main
struct ScreenTimeHelperApp: App {
    @StateObject private var appModel = AppModel()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(appModel)
        }
    }
}
