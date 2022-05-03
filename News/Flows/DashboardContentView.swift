//
//  DashboardContentView.swift
//  News
//

import SwiftUI
import AppTrackingTransparency

/// Tab View tabs
enum CustomTab: String, Identifiable {
    case home = "house.fill"
    case discover = "newspaper.fill"
    case standings = "circle.fill"
    var id: Int { hashValue }
}

/// Main view of the app
struct DashboardContentView: View {

    @ObservedObject private var manager = NewsDataManager()
    
    // MARK: - Main rendering function
    var body: some View {
        TabView {
            BuildTab(.home, view: AnyView(HomeTabView(manager: manager)))
            BuildTab(.discover, view: AnyView(DiscoverTabView(manager: manager)))
        }.onAppear(perform: {
            if #available(iOS 14, *) {
                ATTrackingManager.requestTrackingAuthorization { status in }
            }
        })
    }
    
    /// Create custom tab
    private func BuildTab(_ tab: CustomTab, view: AnyView) -> some View {
        view.tabItem {
            Image(systemName: tab.rawValue)
        }
    }
}

// MARK: - Preview UI
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        DashboardContentView()
    }
}
