//
//  DashboardView.swift
//  ScreenTimeHelper
//
//  Created by Codex on 2026-03-30.
//

import SwiftUI

struct DashboardView: View {
    @ObservedObject var viewModel: DashboardViewModel

    var body: some View {
        NavigationStack {
            Group {
                if let snapshot = viewModel.snapshot {
                    ScrollView {
                        VStack(alignment: .leading, spacing: 20) {
                            HeroCard(snapshot: snapshot, authorizeAction: {
                                Task { await viewModel.requestAuthorization() }
                            })

                            SummaryGrid(summary: snapshot.summary)

                            InsightSection(insights: snapshot.insights)

                            TopAppsSection(apps: snapshot.appUsage)

                            CategorySection(categories: snapshot.categoryUsage)

                            CapabilityNotesSection()
                        }
                        .padding(20)
                    }
                    .background(Color(.systemGroupedBackground))
                } else if viewModel.isLoading {
                    ProgressView("Loading Screen Time analysis...")
                } else {
                    ContentUnavailableView(
                        "No Screen Time Data",
                        systemImage: "hourglass",
                        description: Text("Load the dashboard to review usage patterns and top apps.")
                    )
                }
            }
            .navigationTitle("Screen Time Helper")
            .task {
                guard viewModel.snapshot == nil else { return }
                await viewModel.load()
            }
            .refreshable {
                await viewModel.load()
            }
        }
    }
}

private struct HeroCard: View {
    let snapshot: ScreenTimeSnapshot
    let authorizeAction: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text(snapshot.intervalLabel.uppercased())
                .font(.caption.weight(.semibold))
                .foregroundStyle(.secondary)

            Text("Full usage analysis")
                .font(.largeTitle.bold())

            Text(snapshot.authorizationStatus.detail)
                .foregroundStyle(.secondary)

            HStack(spacing: 12) {
                Label(snapshot.authorizationStatus.title, systemImage: authorizationIcon)
                    .font(.subheadline.weight(.semibold))
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(authorizationColor.opacity(0.14), in: Capsule())
                    .foregroundStyle(authorizationColor)

                Spacer()

                if snapshot.authorizationStatus != .approved {
                    Button("Request Access", action: authorizeAction)
                        .buttonStyle(.borderedProminent)
                }
            }
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            LinearGradient(
                colors: [Color(red: 0.08, green: 0.18, blue: 0.34), Color(red: 0.19, green: 0.47, blue: 0.39)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            ),
            in: RoundedRectangle(cornerRadius: 24, style: .continuous)
        )
        .foregroundStyle(.white)
    }

    private var authorizationIcon: String {
        switch snapshot.authorizationStatus {
        case .approved:
            "checkmark.shield.fill"
        case .denied:
            "xmark.shield.fill"
        case .unknown:
            "questionmark.shield.fill"
        case .unavailable:
            "exclamationmark.shield.fill"
        }
    }

    private var authorizationColor: Color {
        switch snapshot.authorizationStatus {
        case .approved:
            .green
        case .denied, .unavailable:
            .orange
        case .unknown:
            .yellow
        }
    }
}

private struct SummaryGrid: View {
    let summary: UsageSummary

    private let columns = [
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12)
    ]

    var body: some View {
        LazyVGrid(columns: columns, spacing: 12) {
            SummaryTile(title: "Total Screen Time", value: summary.totalUsageSeconds.formattedAsHoursAndMinutes, systemImage: "clock.fill")
            SummaryTile(title: "Average Session", value: "\(summary.averageSessionMinutes)m", systemImage: "timer")
            SummaryTile(title: "Pickups", value: "\(summary.pickupCount)", systemImage: "iphone.gen3")
            SummaryTile(title: "Focus Score", value: "\(summary.focusScore)/100", systemImage: "scope")
        }
    }
}

private struct SummaryTile: View {
    let title: String
    let value: String
    let systemImage: String

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Image(systemName: systemImage)
                .font(.title3.weight(.semibold))
                .foregroundStyle(Color(red: 0.10, green: 0.40, blue: 0.76))

            Text(value)
                .font(.title2.bold())

            Text(title)
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .padding(18)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.background, in: RoundedRectangle(cornerRadius: 20, style: .continuous))
    }
}

private struct InsightSection: View {
    let insights: [UsageInsight]

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionTitle("Analysis")

            ForEach(insights) { insight in
                HStack(alignment: .top, spacing: 12) {
                    Image(systemName: insight.systemImage)
                        .font(.headline)
                        .foregroundStyle(toneColor(insight.tone))
                        .frame(width: 24, height: 24)

                    VStack(alignment: .leading, spacing: 4) {
                        Text(insight.title)
                            .font(.headline)

                        Text(insight.detail)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                }
                .padding(16)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(.background, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
            }
        }
    }

    private func toneColor(_ tone: InsightTone) -> Color {
        switch tone {
        case .positive:
            .green
        case .neutral:
            .blue
        case .caution:
            .orange
        }
    }
}

private struct TopAppsSection: View {
    let apps: [AppUsage]

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionTitle("Most Used Apps")

            ForEach(Array(apps.enumerated()), id: \.element.id) { index, app in
                HStack(spacing: 14) {
                    Text("\(index + 1)")
                        .font(.headline.monospacedDigit())
                        .frame(width: 30)

                    VStack(alignment: .leading, spacing: 4) {
                        Text(app.name)
                            .font(.headline)
                        Text("\(app.category) • \(app.sessions) sessions")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }

                    Spacer()

                    VStack(alignment: .trailing, spacing: 4) {
                        Text(app.usageShareText)
                            .font(.headline)
                        Label(app.trend.description, systemImage: app.trend.symbol)
                            .font(.caption.weight(.medium))
                            .foregroundStyle(.secondary)
                    }
                }
                .padding(16)
                .background(.background, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
            }
        }
    }
}

private struct CategorySection: View {
    let categories: [CategoryUsage]

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionTitle("Category Mix")

            ForEach(categories) { category in
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text(category.name)
                            .font(.headline)
                        Spacer()
                        Text(category.usageSeconds.formattedAsHoursAndMinutes)
                            .font(.subheadline.weight(.semibold))
                    }

                    GeometryReader { proxy in
                        let total = max(categories.reduce(0) { $0 + $1.usageSeconds }, 1)
                        let ratio = category.usageSeconds / total

                        ZStack(alignment: .leading) {
                            RoundedRectangle(cornerRadius: 999)
                                .fill(Color.secondary.opacity(0.15))
                            RoundedRectangle(cornerRadius: 999)
                                .fill(Color(hex: category.colorHex))
                                .frame(width: proxy.size.width * ratio)
                        }
                    }
                    .frame(height: 12)
                }
                .padding(16)
                .background(.background, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
            }
        }
    }
}

private struct CapabilityNotesSection: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionTitle("Implementation Notes")

            Text("iPhone does not allow unrestricted app-usage scraping. Production-grade Screen Time reporting depends on Apple’s Screen Time APIs, the Family Controls entitlement, and often a report extension for real per-app activity views.")
                .font(.subheadline)
                .foregroundStyle(.secondary)

            Text("This build includes the app-side architecture and authorization flow, plus a preview-backed analytics engine so the UI and product logic are ready before the entitlement is wired.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .padding(18)
        .background(.background, in: RoundedRectangle(cornerRadius: 20, style: .continuous))
    }
}

private func sectionTitle(_ title: String) -> some View {
    Text(title)
        .font(.title3.bold())
        .frame(maxWidth: .infinity, alignment: .leading)
}

private extension Color {
    init(hex: String) {
        let sanitized = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var value: UInt64 = 0
        Scanner(string: sanitized).scanHexInt64(&value)

        let r, g, b: UInt64
        switch sanitized.count {
        case 6:
            (r, g, b) = ((value >> 16) & 0xFF, (value >> 8) & 0xFF, value & 0xFF)
        default:
            (r, g, b) = (140, 140, 140)
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: 1
        )
    }
}

struct DashboardView_Previews: PreviewProvider {
    static var previews: some View {
        DashboardView(
            viewModel: DashboardViewModel(
                service: PreviewScreenTimeService(authorizationStatus: .unknown)
            )
        )
    }
}
