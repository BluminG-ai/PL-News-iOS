//
//  RemoteImage.swift
//  News
//

import SwiftUI
import Firebase
import Foundation

// MARK: - Custom image view class to load images from web
struct RemoteImage: View {
    
    @ObservedObject var assetsModel: ArticleAssets
    let imageType: ArticleImageType

    // MARK: - Main rendering function
    public var body: some View {
        assetsModel.fetchAssets()
        let placeholder = UIImage(named: "placeholder")!
        return Image(uiImage: imageType == .hero ? (assetsModel.heroImage ?? placeholder) : (assetsModel.bodyImage ?? placeholder))
            .resizable().aspectRatio(contentMode: .fill)
    }
}
