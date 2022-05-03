//
//  NewsDataManager.swift
//  News
//

import SwiftUI
import Firebase
import Foundation
import GoogleMobileAds

// Main data manager to fetch the news
class NewsDataManager: NSObject, ObservableObject {
    
    /// Dynamic properties that the UI will react to
    @Published var selectedCategory: String = AppConfig.categories[0]
    @Published var latestNews: [ArticleModel]?
    @Published var headerArticle: ArticleModel?
    @Published var categoryNews = [String: [ArticleModel]]()
    @Published var showArticleDetails: Bool = false
    @Published var articleAssetModels = [ArticleAssets]()
    @Published var selectedArticle: ArticleModel? {
        didSet { showArticleDetails = true }
    }
    
    /// AdMob ads
    @Published var nativeAd: GADNativeAdView?
    private var adLoader: GADAdLoader!
    
    /// Get the article asset model based on the article model
    func assetModel(forArticle article: ArticleModel) -> ArticleAssets {
        articleAssetModels.first(where: { $0.identifier == article.id })!
    }
}

// MARK: - Fetch news articles
extension NewsDataManager {
    /// Fetch the latest news based on the time created
    func fetchLatestNews() {
        let newsDispatchGroup = DispatchGroup()
        var newsOfTheDay = [ArticleModel]()
        AppConfig.categories.forEach { newsCategory in
            newsDispatchGroup.enter()
            fetchNewsOfTheDay(category: newsCategory) { news in
                newsOfTheDay.append(contentsOf: news)
                newsDispatchGroup.leave()
            }
        }
        newsDispatchGroup.notify(queue: .main) {
            newsOfTheDay = newsOfTheDay.sorted(by: { $0.createdAt > $1.createdAt })
            self.headerArticle = newsOfTheDay.first
            self.latestNews = newsOfTheDay.count > 1 ? newsOfTheDay.filter({ $0.id != self.headerArticle?.id }) : newsOfTheDay
        }
    }
    
    /// Fetch only th news with `newsOfTheDay` set to true for a given category
    /// - Parameters:
    ///   - category: a category for news
    ///   - completion: returns an array of news matching the query search
    private func fetchNewsOfTheDay(category: String, completion: @escaping (_ data: [ArticleModel]) -> Void) {
        Firestore.firestore().collection(category)
            .whereField("newsOfTheDay", isEqualTo: true) /// get only the news of the day
            .order(by: "createdAt") /// order the news articles by created at (date)
            .limit(toLast: 10) /// get only the last 10 news
            .getDocuments { query, _ in
                var news = [ArticleModel]()
                query?.documents.forEach({ document in
                    var updatedData = document.data()
                    updatedData["id"] = document.documentID
                    if let data = try? JSONSerialization.data(withJSONObject: updatedData, options: []) {
                        if let article = try? JSONDecoder().decode(ArticleModel.self, from: data) {
                            news.append(article)
                            self.articleAssetModels.append(ArticleAssets(articleId: article.id, articleCategory: article.category))
                        }
                    }
                })
                completion(news)
            }
    }
    
    /// Fetch the news for a selected category
    func fetchCurrentCategoryNews() {
        Firestore.firestore().collection(selectedCategory)
            .order(by: "createdAt") /// order the news articles by created at (date)
            .limit(toLast: 50) /// get only the last 50 news per category
            .getDocuments { query, _ in
                var news = [ArticleModel]()
                query?.documents.forEach({ document in
                    var updatedData = document.data()
                    updatedData["id"] = document.documentID
                    if let data = try? JSONSerialization.data(withJSONObject: updatedData, options: []) {
                        if let article = try? JSONDecoder().decode(ArticleModel.self, from: data) {
                            news.append(article)
                            self.articleAssetModels.append(ArticleAssets(articleId: article.id, articleCategory: article.category))
                        }
                    }
                })
                DispatchQueue.main.async {
                    self.categoryNews[self.selectedCategory] = news.sorted(by: { $0.createdAt > $1.createdAt })
                }
            }
    }
}

// MARK: - Native Ads handler
extension NewsDataManager: GADNativeAdLoaderDelegate {

    /// Load native ads
    func loadNativeAds() {
        if AppConfig.showNativeAds {
            adLoader = GADAdLoader(adUnitID: AppConfig.nativeAdId, rootViewController: nil,
                                       adTypes: [.native], options: nil)
            adLoader.delegate = self
            adLoader.load(GADRequest())
        }
    }
    
    /// Ad loading failure
    func adLoader(_ adLoader: GADAdLoader, didFailToReceiveAdWithError error: Error) { }
    
    /// Ad loading success
    func adLoader(_ adLoader: GADAdLoader, didReceive nativeAd: GADNativeAd) {
        let nibView = Bundle.main.loadNibNamed("NativeAdView", owner: nil, options: nil)?.first
        guard let nativeAdView = nibView as? GADNativeAdView else { return }
        self.nativeAd = nativeAdView
        (nativeAdView.headlineView as? UILabel)?.text = nativeAd.headline
        nativeAdView.mediaView?.mediaContent = nativeAd.mediaContent
        
        (nativeAdView.bodyView as? UILabel)?.text = nativeAd.body
        nativeAdView.bodyView?.isHidden = nativeAd.body == nil
        
        (nativeAdView.callToActionView as? UIButton)?.setTitle(nativeAd.callToAction, for: .normal)
        nativeAdView.callToActionView?.isHidden = nativeAd.callToAction == nil
        
        (nativeAdView.iconView as? UIImageView)?.image = nativeAd.icon?.image
        nativeAdView.iconView?.isHidden = nativeAd.icon == nil
        nativeAdView.starRatingView?.isHidden = true
        
        (nativeAdView.storeView as? UILabel)?.text = nativeAd.store
        nativeAdView.storeView?.isHidden = nativeAd.store == nil
        
        (nativeAdView.priceView as? UILabel)?.text = nativeAd.price
        nativeAdView.priceView?.isHidden = nativeAd.price == nil
        
        (nativeAdView.advertiserView as? UILabel)?.text = nativeAd.advertiser
        nativeAdView.advertiserView?.isHidden = nativeAd.advertiser == nil
        
        nativeAdView.callToActionView?.isUserInteractionEnabled = false
        nativeAdView.nativeAd = nativeAd
    }
}

