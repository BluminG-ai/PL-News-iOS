//
//  AppConfig.swift
//  News
//

import SwiftUI
import Foundation

/// Generic configurations for the app
class AppConfig {
    
    /// This is the AdMob Interstitial ad id
    /// Test App ID: ca-app-pub-3940256099942544~1458002511
    /// Test Native ID: ca-app-pub-3940256099942544/3986624511
    static let nativeAdId: String = "ca-app-pub-9622689527396334/9128863445"
    static let showNativeAds: Bool = true
    
    // MARK: - News Categories
    static let categories = ["Man City", "Liverpool", "Chelsea", "Man Utd", "Arsenal", "Leicester City", "Aston Villa", "Tottenham", "West Ham", "Wolves", "Newcastle", "Brighton", "Brentford", "Southampton", "Crystal Palace"]
    static let newsOfTheDay = "News of the Day"
    static let breakingNews = "Breaking News"
    
    // MARK: - UI Configurations
    static let homeHeaderArticleHeight: CGFloat = UIScreen.main.bounds.height/2
    static let homeHeaderImageCornerRadius: CGFloat = 40.0
    static let homeLatestCarouselImageWidth: CGFloat = UIScreen.main.bounds.width/2
    static let homeLatestCarouselImageHeight: CGFloat = UIScreen.main.bounds.height/3.7
    
    // MARK: - Content placeholder while loading data
    static let placeholderLong = "Lorem Ipsum is simply dummy text of the printing and typesetting industry."
    static let placeholderShort = "Lorem Ipsum is"
}
