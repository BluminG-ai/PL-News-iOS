//
//  ArticleModel.swift
//  News
//

import UIKit
import SwiftUI
import Firebase
import Foundation

/// A simple model to parse the news article data
struct ArticleModel: Codable {
    let id: String
    let headline: String
    let author: String
    let lead: String
    let body: String
    let tail: String
    let category: String
    let breakingNews: Bool
    let newsOfTheDay: Bool
    let createdAt: Double
    
    /// Returns formatted time for when the article was posted. Ex: 2hrs ago
    var time: String {
        Date().timeAgo(from: Date(timeIntervalSince1970: createdAt))
    }
    
    /// Formatted author
    var byAuthor: String {
        "by \(author)"
    }
    
    /// News type. It can be News of the Day or Breaking News for the header view on the Home Tab
    var newsType: String {
        breakingNews ? AppConfig.breakingNews : (newsOfTheDay ? AppConfig.newsOfTheDay : category)
    }
    
    /// Create a demo model for news placeholder
    static var demo: ArticleModel {
        ArticleModel(id: "demo", headline: AppConfig.placeholderLong, author: "Alex P.", lead: "", body: "", tail: "", category: "", breakingNews: false, newsOfTheDay: true, createdAt: 0.0)
    }
}

/// Image type for an article
enum ArticleImageType: String {
    case hero, body
}

// MARK: - A model to handle article images
class ArticleAssets: ObservableObject {
    /// Dynamic properties that the UI will react to
    @Published var heroImage: UIImage?
    @Published var bodyImage: UIImage?
    
    /// Article identifier
    var identifier: String = ""
    private var category: String = ""
    
    /// Init with the unique id for an article
    /// - Parameter articleId: unique article identifier
    init(articleId: String, articleCategory: String) {
        identifier = articleId
        category = articleCategory
    }
    
    /// Public APIs
    func fetchAssets() {
        fetchAssets(imageType: .hero)
        fetchAssets(imageType: .body)
    }
    
    /// Private APIs
    private func fetchAssets(imageType: ArticleImageType) {
        if imageType == .hero && heroImage != nil { return }
        if imageType == .body && bodyImage != nil { return }
        let cacheKey = "\(identifier)-\(imageType)"
        if let documentsData = loadImageFromDocumentDirectory(fileName: cacheKey)?.jpegData(compressionQuality: 1.0) {
            DispatchQueue.main.async {
                if imageType == .hero { self.heroImage = UIImage(data: documentsData) } else {
                    self.bodyImage = UIImage(data: documentsData)
                }
            }
        }
        
        /// Get the news hero image based on a news id if available
        Storage.storage().reference().child("\(category)/\(identifier)/\(imageType.rawValue).jpg").downloadURL { url, _ in
            DispatchQueue.main.async {
                if let imageUrl = url?.absoluteString {
                    self.fetchImage(forURL: imageUrl, savingKey: cacheKey)
                }
            }
        }
    }
    
    private func fetchImage(forURL imageUrl: String, savingKey: String) {
        guard let url = URL(string: imageUrl) else { return }
        URLSession.shared.dataTask(with: url) { (data, _, _) in
            DispatchQueue.main.async {
                if let imageData = data, let image = UIImage(data: imageData) {
                    if savingKey.contains(ArticleImageType.hero.rawValue) { self.heroImage = image } else {
                        self.bodyImage = image
                    }
                }
            }
        }.resume()
    }
    
    private func saveImageInDocumentDirectory(image: UIImage, fileName: String) {
        guard let documentsUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else { return }
        let fileURL = documentsUrl.appendingPathComponent(fileName.replacingOccurrences(of: "/", with: "_"))
        if let imageData = image.jpegData(compressionQuality: 1.0) {
            try? imageData.write(to: fileURL, options: .atomic)
        }
    }
    
    public func loadImageFromDocumentDirectory(fileName: String) -> UIImage? {
        guard let documentsUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else { return nil }
        let fileURL = documentsUrl.appendingPathComponent(fileName.replacingOccurrences(of: "/", with: "_"))
        do {
            let imageData = try Data(contentsOf: fileURL)
            return UIImage(data: imageData)
        } catch {}
        return nil
    }
}

/// Format time from date
extension Date {
    // Returns the number of years
    func yearsCount(from date: Date) -> Int {
        return Calendar.current.dateComponents([.year], from: date, to: self).year ?? 0
    }
    
    // Returns the number of months
    func monthsCount(from date: Date) -> Int {
        return Calendar.current.dateComponents([.month], from: date, to: self).month ?? 0
    }
    
    // Returns the number of weeks
    func weeksCount(from date: Date) -> Int {
        return Calendar.current.dateComponents([.weekOfMonth], from: date, to: self).weekOfMonth ?? 0
    }
    
    // Returns the number of days
    func daysCount(from date: Date) -> Int {
        return Calendar.current.dateComponents([.day], from: date, to: self).day ?? 0
    }
    
    // Returns the number of hours
    func hoursCount(from date: Date) -> Int {
        return Calendar.current.dateComponents([.hour], from: date, to: self).hour ?? 0
    }
    
    // Returns the number of minutes
    func minutesCount(from date: Date) -> Int {
        return Calendar.current.dateComponents([.minute], from: date, to: self).minute ?? 0
    }
    
    // Returns the number of seconds
    func secondsCount(from date: Date) -> Int {
        return Calendar.current.dateComponents([.second], from: date, to: self).second ?? 0
    }
    
    // Returns time ago by checking if the time differences between two dates are in year or months or weeks or days or hours or minutes or seconds
    func timeAgo(from date: Date) -> String {
        if yearsCount(from: date)   > 0 { return "\(yearsCount(from: date))y ago"   }
        if monthsCount(from: date)  > 0 { return "\(monthsCount(from: date))m ago"  }
        if weeksCount(from: date)   > 0 { return "\(weeksCount(from: date))w ago"   }
        if daysCount(from: date)    > 0 { return "\(daysCount(from: date))d ago"    }
        if hoursCount(from: date)   > 0 { return "\(hoursCount(from: date))h ago"   }
        if minutesCount(from: date) > 0 { return "\(minutesCount(from: date))m ago" }
        if secondsCount(from: date) > 0 { return "\(secondsCount(from: date))s ago" }
        return ""
    }
}
