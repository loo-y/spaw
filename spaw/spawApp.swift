//
//  spawApp.swift
//  spaw
//
//  Created by Loo on 2024/10/2.
//

import SwiftUI
import SwiftData


@main
struct spawApp: App {
//    let appDelegate: AppDelegate
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    @StateObject private var notificationService: NotificationService

    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Message.self,
            UserSettings.self
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()


    init() {
        do {
            let context = sharedModelContainer.mainContext
            let notificationService = NotificationService(modelContext: context)
            _notificationService = StateObject(wrappedValue: notificationService)
            appDelegate.notificationService = notificationService

            // 设置接收远程通知
//            UIApplication.shared.registerForRemoteNotifications()

        } catch {
            fatalError("Failed to create ModelContainer: \(error.localizedDescription)")
        }
    }
    

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(self.notificationService)
                .onAppear {
                    self.notificationService.requestAuthorization()
                }
        }
        .modelContainer(sharedModelContainer)
    }

}

class AppDelegate: NSObject, UIApplicationDelegate {
    var notificationService: NotificationService?
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        print("尝试获取deviceToken")
        print("Device Token: \(deviceToken.map { String(format: "%02.2hhx", $0) }.joined())") // 将 Data 转换为可打印的十六进制字符串
        notificationService?.registerDeviceToken(deviceToken)
    }
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("Failed to register for remote notifications: \(error)")
    }
}
