//
//  ContentView.swift
//  ScreenTimeHelper
//
//  Created by Codex on 2026-03-30.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject private var appModel: AppModel

    var body: some View {
        DashboardView(viewModel: appModel.dashboardViewModel)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(AppModel())
    }
}
