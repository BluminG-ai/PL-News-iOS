//
//  NewsApp.swift
//  News
//

import SwiftUI
import Firebase

@main
struct NewsApp: App {
    
    @State private var didShowOnboardingFlow: Bool = UserDefaults.standard.bool(forKey: "didShowOnboardingFlow")
    @UIApplicationDelegateAdaptor private var appDelegate: AppDelegate
    
    // MARK: - Main rendering function
    var body: some Scene {
        UITableViewCell.appearance().backgroundColor = .clear
        UITableView.appearance().backgroundColor = .clear
        return WindowGroup {
            if didShowOnboardingFlow == false {
                ClassicOnboarding
            } else {
                DashboardContentView()
            }
        }
    }
    
    // MARK: - ClassicOnboardingView
    private var ClassicOnboarding: some View {
        var pages = [ClassicOnboardingView.PageDetails]()
        pages = [
            .init(imageName: "news-page-1", title: "Quality News", subtitle: "Get some great quality Premier League news each day. Filter by categories."),
            .init(imageName: "news-page-2", title: "Get Notified", subtitle: "Enable push notifications, so you can get notified when important news are posted")
        ]
        return ClassicOnboardingView(pages: pages, exitAction: {
            /// Here you can add the logic to take the user to your main view of the app
            didShowOnboardingFlow = true
            UserDefaults.standard.setValue(true, forKeyPath: "didShowOnboardingFlow")
            UserDefaults.standard.synchronize()
        })
    }
}

// MARK: - AppDelegate class
class AppDelegate: NSObject, UIApplicationDelegate, UNUserNotificationCenterDelegate, MessagingDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        FirebaseApp.configure()
        Messaging.messaging().delegate = self
        registerPushNotifications()
        return true
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        Messaging.messaging().apnsToken = deviceToken
        DispatchQueue.main.async {
            Messaging.messaging().subscribe(toTopic: "news-updates") { error in }
        }
    }
    
    /// Print the push token into the logs, so you can use it to debug/test the push notifications
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        #if DEBUG
        print("\nPUSH TOKEN\n")
        print(fcmToken ?? "NOT_FOUND")
        print("\n")
        #endif
    }
    
    private func registerPushNotifications() {
        UNUserNotificationCenter.current().delegate = self
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) {
            (granted, error) in
            guard granted else { return }
            UNUserNotificationCenter.current().getNotificationSettings { (settings) in
                guard settings.authorizationStatus == .authorized else { return }
                DispatchQueue.main.async {
                    UIApplication.shared.registerForRemoteNotifications()
                }
            }
        }
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.sound, .banner, .list])
    }
}
