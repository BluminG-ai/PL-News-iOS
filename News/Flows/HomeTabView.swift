//
//  HomeTabView.swift
//  News
//

import SwiftUI

/// Default home tab view of the app
struct HomeTabView: View {
    
    @ObservedObject var manager: NewsDataManager
    
    // MARK: - Main rendering function
    var body: some View {
        VStack {
            HeaderArticleView
            LatestNewsCarouselView
            Spacer(minLength: 30)
        }.onAppear(perform: {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                manager.fetchLatestNews()
            }
        }).fullScreenCover(isPresented: $manager.showArticleDetails, content: {
            ArticleDetailsContentView(manager: manager)
        })
    }
    
    // MARK: - Header news image view
    private var HeaderArticleView: some View {
        ZStack {
            HeaderArticleImageView
            VStack(alignment: .leading, spacing: 20) {
                Spacer()
                Text(manager.headerArticle?.newsType ?? AppConfig.newsOfTheDay)
                    .font(.system(size: 15))
                    .foregroundColor(manager.headerArticle?.newsType == AppConfig.breakingNews ? .white : .black)
                    .padding([.leading, .trailing]).padding([.top, .bottom], 10)
                    .background(
                        RoundedRectangle(cornerRadius: 30)
                            .foregroundColor(manager.headerArticle?.newsType == AppConfig.breakingNews ? .red : .white)
                            .opacity(0.8))
                HStack {
                    Text(manager.headerArticle?.headline ?? AppConfig.placeholderLong)
                        .redacted(reason: manager.headerArticle?.headline == nil ? .placeholder : [])
                        .font(.system(size: 22, weight: .bold))
                        .foregroundColor(.white).lineLimit(3)
                    Spacer()
                }
                Button(action: {
                    UIImpactFeedbackGenerator().impactOccurred()
                    manager.selectedArticle = manager.headerArticle
                }, label: {
                    HStack {
                        Text("Learn More")
                        Image(systemName: "arrow.right")
                    }.font(.system(size: 20, weight: .bold))
                })
                .foregroundColor(.white).padding(.bottom)
                .disabled(manager.headerArticle == nil)
            }.padding(35)
        }.frame(height: AppConfig.homeHeaderArticleHeight)
    }
    
    /// Header article image and overlay gradient
    private var HeaderArticleImageView: some View {
        let colors = manager.headerArticle?.id == nil ? [Color.black.opacity(0.1), Color.black.opacity(0.4)] : [Color.clear, Color.clear, Color.black.opacity(0.4)]
        return ZStack {
            if manager.headerArticle?.id != nil {
                RemoteImage(assetsModel: manager.assetModel(forArticle: manager.headerArticle!), imageType: .hero)
                    .frame(width: UIScreen.main.bounds.width)
                    .mask(RoundedCorner(radius: AppConfig.homeHeaderImageCornerRadius, corners: [.bottomLeft, .bottomRight]))
                    .edgesIgnoringSafeArea(.top)
            }
            LinearGradient(gradient: Gradient(colors: colors),
                           startPoint: .top, endPoint: .bottom)
                .mask(RoundedCorner(radius: AppConfig.homeHeaderImageCornerRadius, corners: [.bottomLeft, .bottomRight]))
                .edgesIgnoringSafeArea(.top)
        }.shadow(color: Color.black.opacity(0.4), radius: 20)
    }
    
    // MARK: - Latest news carousel
    private var LatestNewsCarouselView: some View {
        let news = manager.latestNews ?? [ArticleModel](repeating: ArticleModel.demo, count: 3)
        return VStack(alignment: .leading, spacing: 5) {
            Text("Latest news").font(.system(size: 30, weight: .bold))
                .padding(.leading, 35).padding(.top, 30)
            ScrollView(.horizontal, showsIndicators: false, content: {
                HStack(spacing: 30) {
                    Spacer(minLength: 1)
                    ForEach(0..<news.count, id: \.self, content: { index in
                        BuildArticle(news[index])
                    })
                    Spacer(minLength: 1)
                }
            })
        }
    }
    
    /// Create a news article for the carousel
    private func BuildArticle(_ model: ArticleModel) -> some View {
        Button(action: {
            UIImpactFeedbackGenerator().impactOccurred()
            manager.selectedArticle = model
        }, label: {
            VStack(alignment: .leading, spacing: 10) {
                ZStack {
                    if model.id != "demo" {
                        RemoteImage(assetsModel: manager.assetModel(forArticle: model), imageType: .hero)
                    } else {
                        Image(systemName: "text.below.photo")
                            .font(.system(size: 40)).opacity(0.5)
                        RoundedRectangle(cornerRadius: 20).opacity(0.03)
                    }
                }
                .frame(height: AppConfig.homeLatestCarouselImageHeight/2)
                .frame(width: AppConfig.homeLatestCarouselImageWidth)
                .mask(RoundedRectangle(cornerRadius: 20)).clipped()
            
                VStack(alignment: .leading) {
                    Text(model.headline)
                        .redacted(reason: model.id == "demo" ? .placeholder : []).lineLimit(2)
                    Text(model.time.isEmpty ? "time ago" : model.time).opacity(0.2)
                    Text(model.byAuthor).opacity(0.4)
                }.redacted(reason: model.id == "demo" ? .placeholder : [])
            }.frame(width: AppConfig.homeLatestCarouselImageWidth, height: AppConfig.homeLatestCarouselImageHeight)
        }).disabled(model.id == "demo")
    }
}

// MARK: - Preview UI
struct HomeTabView_Previews: PreviewProvider {
    static var previews: some View {
        HomeTabView(manager: NewsDataManager())
    }
}
