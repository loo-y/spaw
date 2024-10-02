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
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()
    
    // @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    private func requestNotificationPermissionAndRegister() {
            UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
                if granted {
                    print("通知权限已授予111")
                    DispatchQueue.main.async {
                        UIApplication.shared.registerForRemoteNotifications()
                        print("尝试注册远程通知")
                    }
                } else {
                    print("通知权限被拒绝111")
                }
            }
        }

    init() {
        do {
//            let container = try ModelContainer(for: Message.self)
//            let context = container.mainContext
            let context = sharedModelContainer.mainContext
            let notificationService = NotificationService(modelContext: context)
            _notificationService = StateObject(wrappedValue: NotificationService(modelContext: context))
            appDelegate.notificationService = notificationService
//            self.appDelegate = AppDelegate(notificationService: notificationService)
//            UIApplication.shared.delegate = self.appDelegate

            // 设置接收远程通知
//            UIApplication.shared.registerForRemoteNotifications()
//            requestNotificationPermissionAndRegister()
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


// 扩展 App 以处理远程通知
// extension spawApp {
//     func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
//         print("尝试获取deviceToken")
//         notificationService.registerDeviceToken(deviceToken)
//     }
    
//     func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
//         print("Failed to register for remote notifications: \(error)")
//     }
// }

class AppDelegate: NSObject, UIApplicationDelegate {
    var notificationService: NotificationService?
//    let notificationService: NotificationService
    //
    //    init(notificationService: NotificationService) {
    //        print("appDelegate!!!")
    //        self.notificationService = notificationService
    //        super.init()
    //    }
    //

    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        print("尝试获取deviceToken")
        print("Device Token: \(deviceToken.map { String(format: "%02.2hhx", $0) }.joined())") // 将 Data 转换为可打印的十六进制字符串
        notificationService?.registerDeviceToken(deviceToken)
    }
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("Failed to register for remote notifications: \(error)")
    }
}
