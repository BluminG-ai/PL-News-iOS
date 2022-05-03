//
//  DiscoverTabView.swift
//  News
//

import SwiftUI

/// Discover tab view
struct DiscoverTabView: View {
    
    @ObservedObject var manager: NewsDataManager
    
    // MARK: - Main rendering function
    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            Text("PL News").font(.system(size: 40, weight: .black))
                .padding(.leading, 20).padding(.top)
            VStack(spacing: 0) {
                CategoriesPickerView
                List {
                    ForEach(0..<categoryArticles.count, id: \.self, content: { index in
                        NewsArticleListItem(model: categoryArticles[index])
                    })
                }
            }
        }.onAppear {
            manager.fetchCurrentCategoryNews()
        }
    }
    
    /// News articles
    private var categoryArticles: [ArticleModel] {
        let news = manager.categoryNews[manager.selectedCategory]
        return news?.count ?? 0 > 0 ? news! : [ArticleModel](repeating: ArticleModel.demo, count: 10)
    }
    
    /// Create a news list item
    private func NewsArticleListItem(model: ArticleModel) -> some View {
        Button(action: {
            UIImpactFeedbackGenerator().impactOccurred()
            manager.selectedArticle = model
        }, label: {
            HStack(spacing: 15) {
                ZStack {
                    RoundedRectangle(cornerRadius: 15)
                        .foregroundColor(Color(#colorLiteral(red: 0.9358181953, green: 0.9291332364, blue: 0.9409376979, alpha: 1)))
                        .frame(width: 100, height: 100, alignment: .center)
                    if model.id != "demo" {
                        RemoteImage(assetsModel: manager.assetModel(forArticle: model), imageType: .hero)
                            .frame(width: 100, height: 100, alignment: .center)
                            .mask(RoundedRectangle(cornerRadius: 15))
                    }
                }
                VStack(spacing: 10) {
                    HStack {
                        Text(model.headline).bold().lineLimit(2).font(.system(size: 20))
                        Spacer()
                    }
                    HStack {
                        Image(systemName: "clock")
                        Text(model.time)
                        Spacer()
                    }.opacity(0.5)
                }.redacted(reason: model.id == "demo" ? .placeholder : [])
            }
        })
        .disabled(model.id == "demo")
        .listRowInsets(EdgeInsets(top: 20, leading: 20, bottom: 20, trailing: 10))
    }
    
    /// Categories selector view
    private var CategoriesPickerView: some View {
        VStack(alignment: .leading) {
            Text("Things to know this PL week")
                .padding(.leading, 22).padding(.bottom, 10)
                .opacity(0.6).offset(y: -5)
            ScrollView(.horizontal, showsIndicators: false, content: {
                HStack(spacing: 30) {
                    Spacer(minLength: -8)
                    ForEach(0..<AppConfig.categories.count, id: \.self, content: { index in
                        Button(action: {
                            UIImpactFeedbackGenerator().impactOccurred()
                            manager.selectedCategory = AppConfig.categories[index]
                            manager.fetchCurrentCategoryNews()
                        }, label: {
                            Text(AppConfig.categories[index])
                                .opacity(manager.selectedCategory == AppConfig.categories[index] ? 1 : 0.3)
                                .font(.system(size: 23, weight: .bold))
                                .padding(.bottom, 10).fixedSize(horizontal: true, vertical: false)
                                .background(
                                    VStack {
                                        if manager.selectedCategory == AppConfig.categories[index] {
                                            Spacer()
                                            RoundedRectangle(cornerRadius: 10)
                                                .frame(height: 5)
                                        }
                                    }
                                )
                        })
                    })
                    Spacer(minLength: -8)
                }
            }).background(
                VStack {
                    Spacer()
                    Rectangle().frame(height: 3)
                }.opacity(0.1).offset(y: -1)
            )
        }
    }
}

// MARK: - Preview UI
struct DiscoverTabView_Previews: PreviewProvider {
    static var previews: some View {
        DiscoverTabView(manager: NewsDataManager())
    }
}
