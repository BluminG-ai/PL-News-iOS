//
//  ArticleDetailsContentView.swift
//  News
//

import SwiftUI

// MARK: - Article sections
enum ArticleSection: CaseIterable, Identifiable {
    case authorTime, headline, lead, nativeAd, body, image, tail
    var id: Int { hashValue }
}

/// Shows a full article details views
struct ArticleDetailsContentView: View {
    
    @ObservedObject var manager: NewsDataManager
    @Environment(\.presentationMode) var presentation

    // MARK: - Main rendering function
    var body: some View {
        ZStack {
            HeaderArticleView
            ArticleContentView
            CloseButtonView
        }.onAppear {
            manager.loadNativeAds()
        }
    }
    
    /// Close article button
    private var CloseButtonView: some View {
        VStack {
            HStack {
                Spacer()
                Button(action: {
                    UIImpactFeedbackGenerator().impactOccurred()
                    presentation.wrappedValue.dismiss()
                }, label: {
                    ZStack {
                        Circle().foregroundColor(.white).frame(width: 28, height: 28)
                        Image(systemName: "xmark.circle.fill").font(.system(size: 30))
                    }
                })
            }
            Spacer()
        }.padding()
    }
    
    /// Header view for an article
    private var HeaderArticleView: some View {
        VStack {
            ZStack {
                HeaderArticleImageView
                VStack(alignment: .leading, spacing: 20) {
                    Spacer()
                    Text(manager.selectedArticle?.category ?? AppConfig.newsOfTheDay)
                        .font(.system(size: 15))
                        .foregroundColor(manager.selectedArticle?.newsType == AppConfig.breakingNews ? .white : .black)
                        .padding([.leading, .trailing]).padding([.top, .bottom], 10)
                        .background(
                            RoundedRectangle(cornerRadius: 30)
                                .foregroundColor(manager.selectedArticle?.newsType == AppConfig.breakingNews ? .red : .white)
                                .opacity(0.8))
                    HStack {
                        Text(manager.selectedArticle?.headline ?? AppConfig.placeholderLong)
                            .redacted(reason: manager.selectedArticle?.headline == nil ? .placeholder : [])
                            .font(.system(size: 22, weight: .bold))
                            .foregroundColor(.white).lineLimit(2)
                        Spacer()
                    }
                }.padding(35).padding(.bottom, 70)
            }.frame(height: UIScreen.main.bounds.height/2.3)
            RoundedCorner(radius: AppConfig.homeHeaderImageCornerRadius, corners: [.topLeft, .topRight])
                .foregroundColor(.white).offset(y: -40)
            Spacer()
        }
    }
    
    /// Header article image and overlay gradient
    private var HeaderArticleImageView: some View {
        let colors = manager.selectedArticle == nil ? [Color.black.opacity(0.1), Color.black.opacity(0.4)] : [Color.clear, Color.clear, Color.black.opacity(0.5)]
        return ZStack {
            if manager.selectedArticle != nil {
                RemoteImage(assetsModel: manager.assetModel(forArticle: manager.selectedArticle!), imageType: .hero)
                    .frame(width: UIScreen.main.bounds.width)
                    .frame(height: UIScreen.main.bounds.height/2)
                    .clipped().edgesIgnoringSafeArea(.top)
            }
            LinearGradient(gradient: Gradient(colors: colors),
                           startPoint: .top, endPoint: .bottom)
                .frame(height: UIScreen.main.bounds.height/2)
                .edgesIgnoringSafeArea(.top)
        }
    }
    
    /// Article content view
    private var ArticleContentView: some View {
        manager.assetModel(forArticle: manager.selectedArticle!).fetchAssets()
        return ScrollView(.vertical, showsIndicators: false, content: {
            Spacer(minLength: UIScreen.main.bounds.height/2.5)
            VStack(alignment: .leading, spacing: 15) {
                ForEach(ArticleSection.allCases, content: { item in
                    switch item {
                    case .authorTime:
                        ArticleAuthorTimeView
                    case .headline:
                        Text(manager.selectedArticle?.headline ?? "")
                            .font(.system(size: 20, weight: .bold)).padding(.top)
                            .fixedSize(horizontal: false, vertical: true)
                    case .lead:
                        Text(manager.selectedArticle?.lead ?? "").italic().foregroundColor(Color(#colorLiteral(red: 0.6000000238, green: 0.6000000238, blue: 0.6000000238, alpha: 1)))
                            .fixedSize(horizontal: false, vertical: true)
                    case .nativeAd:
                        if manager.nativeAd != nil {
                            HStack {
                                Spacer()
                                NativeAd(adView: manager.nativeAd!)
                                    .frame(width: UIScreen.main.bounds.width - 80, height: 350)
                                    .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color(#colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)), lineWidth: 1))
                                Spacer()
                            }
                        }
                    case .body:
                        Text(manager.selectedArticle?.body ?? "")
                            .font(.system(size: 20)).foregroundColor(Color(#colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1)))
                            .fixedSize(horizontal: false, vertical: true)
                    case .image:
                        if manager.selectedArticle != nil
                            && manager.assetModel(forArticle: manager.selectedArticle!).bodyImage != nil {
                            HStack {
                                Spacer()
                                RemoteImage(assetsModel: manager.assetModel(forArticle: manager.selectedArticle!), imageType: .body)
                                    .frame(width: UIScreen.main.bounds.width - 80)
                                    .frame(height: UIScreen.main.bounds.width/2)
                                    .mask(RoundedRectangle(cornerRadius: 15))
                                Spacer()
                            }
                        }
                    case .tail:
                        Text(manager.selectedArticle?.tail ?? "").italic().foregroundColor(Color(#colorLiteral(red: 0.6000000238, green: 0.6000000238, blue: 0.6000000238, alpha: 1)))
                            .fixedSize(horizontal: false, vertical: true)
                    }
                })
            }.padding(30).padding(.top, 5).background(
                RoundedCorner(radius: AppConfig.homeHeaderImageCornerRadius, corners: [.topLeft, .topRight])
                    .foregroundColor(.white)
            )
        })
    }
    
    /// Article author and date view
    private var ArticleAuthorTimeView: some View {
        HStack {
            HStack {
                Image(systemName: "person.crop.circle")
                Text(manager.selectedArticle?.author ?? "Author").lineLimit(1)
            }.foregroundColor(.white).padding([.leading, .trailing]).padding([.top, .bottom], 10).background(
                RoundedRectangle(cornerRadius: 30).opacity(0.75)
            )
            Spacer()
            HStack {
                Image(systemName: "clock")
                Text(manager.selectedArticle?.time ?? "today").lineLimit(1)
            }.foregroundColor(.black).padding([.leading, .trailing]).padding([.top, .bottom], 10).background(
                RoundedRectangle(cornerRadius: 30).foregroundColor(Color(#colorLiteral(red: 0.951993525, green: 0.9451927543, blue: 0.9572014213, alpha: 1)))
            )
        }
    }
}

// MARK: - Preview UI
struct ArticleDetailsContentView_Previews: PreviewProvider {
    static var previews: some View {
        let manager = NewsDataManager()
        manager.selectedArticle = ArticleModel.demo
        manager.articleAssetModels = [ArticleAssets(articleId: "demo", articleCategory: "Health")]
        return ArticleDetailsContentView(manager: manager)
    }
}
