//
//  ClassicOnboardingView.swift
//  Onboarding
//

import SwiftUI

/// Shows a simple white background
struct ClassicOnboardingView: View {
    
    @State var pages = [PageDetails]()
    @State private var pageIndex: Int = 0
    private let bottomSectionHeight: CGFloat = 100
    var exitAction: () -> Void
    
    // MARK: - Main rendering function
    var body: some View {
        ZStack {
            ScrollView {
                TabView(selection: $pageIndex.animation(.easeIn)) {
                    ForEach(0..<pages.count, id: \.self, content: { index in
                        CreatePage(details: pages[index])
                    })
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                .frame(height: UIScreen.main.bounds.height)
            }.edgesIgnoringSafeArea(.all).onAppear {
                UIScrollView.appearance().bounces = false
            }
            BottomSectionView
        }
    }
    
    // MARK: - Configuration
    struct PageDetails {
        let imageName: String
        let title: String
        let subtitle: String
    }
    
    /// Create a page with details
    private func CreatePage(details: PageDetails) -> some View {
        return ZStack {
            VStack {
                if pageIndex % 2 == 0 {
                    Spacer()
                    ImageSection(details: details)
                    TitleSubtitleSection(details: details, topSpacing: 0)
                        .padding(.bottom, bottomSectionHeight/2)
                } else {
                    TitleSubtitleSection(details: details, topSpacing: 100)
                    ImageSection(details: details).padding(.bottom, bottomSectionHeight/2)
                }
                Color.clear.frame(height: bottomSectionHeight)
            }.padding().multilineTextAlignment(.center)
        }.frame(width: UIScreen.main.bounds.width).foregroundColor(.white)
    }
    
    private func TitleSubtitleSection(details: PageDetails, topSpacing: CGFloat) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: 20) {
                Text(details.title).font(.system(size: 35, weight: .semibold, design: .rounded))
                Text(details.subtitle).font(.system(size: 18))
            }.foregroundColor(.black).multilineTextAlignment(.leading)
            Spacer()
        }.padding().padding(.top, topSpacing)
    }
    
    private func ImageSection(details: PageDetails) -> some View {
        let imageSize = UIScreen.main.bounds.width-100
        return VStack {
            Spacer()
            if UIImage(named: details.imageName) != nil {
                Image(uiImage: UIImage(named: details.imageName)!)
                    .resizable().aspectRatio(contentMode: .fit)
                    .frame(width: imageSize, height: imageSize, alignment: .center)
            } else {
                Color.clear.frame(height: imageSize)
            }
            Spacer()
        }
    }
    
    /// Page dots and CTA buttons view
    private var BottomSectionView: some View {
        let pageDotSize: CGFloat = 10
        return VStack {
            Spacer()
            HStack {
                /// Page dots section
                HStack {
                    ForEach(0..<pages.count, id: \.self, content: { id in
                        Circle().opacity(id == pageIndex ? 1 : 0.3)
                            .frame(width: pageDotSize, height: pageDotSize)
                    })
                }.foregroundColor(.black)
                Spacer()
                Button(action: {
                    UIImpactFeedbackGenerator().impactOccurred()
                    if pageIndex < pages.count - 1 {
                        withAnimation { pageIndex = pageIndex + 1 }
                    } else {
                        exitAction()
                    }
                }, label: {
                    ZStack {
                        Circle().foregroundColor(Color(#colorLiteral(red: 0.04440700263, green: 0.09145442396, blue: 0.3269890547, alpha: 1))).frame(width: 70, height: 70)
                        Text("Next").foregroundColor(.white)
                            .font(.system(size: 20, weight: .semibold))
                    }
                })
            }.padding([.leading, .trailing], 25).foregroundColor(.black)
            .frame(height: bottomSectionHeight)
        }
    }
}

// MARK: - Preview UI
struct ClassicOnboardingView_Previews: PreviewProvider {
    static var previews: some View {
        let pages: [ClassicOnboardingView.PageDetails] = [
            ClassicOnboardingView
                .PageDetails(imageName: "classic0", title: "Order Your Food", subtitle: "Now you can order food any time right from your phone."),
            ClassicOnboardingView
                .PageDetails(imageName: "classic1", title: "Easy & Healthy", subtitle: "Find thousands of easy and healthy recipes")
        ]
        return ClassicOnboardingView(pages: pages, exitAction: { })
    }
}
