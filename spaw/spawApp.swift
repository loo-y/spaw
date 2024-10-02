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

    init() {
        do {
//            let container = try ModelContainer(for: Message.self)
//            let context = container.mainContext
            let context = sharedModelContainer.mainContext
            _notificationService = StateObject(wrappedValue: NotificationService(modelContext: context))
            
            // 设置接收远程通知
            UIApplication.shared.registerForRemoteNotifications()
        } catch {
            fatalError("Failed to create ModelContainer: \(error.localizedDescription)")
        }
    }
    

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(notificationService)
                .onAppear {
                    notificationService.requestAuthorization()
                }
        }
        .modelContainer(sharedModelContainer)
    }

}


// 扩展 App 以处理远程通知
extension spawApp {
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        notificationService.registerDeviceToken(deviceToken)
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("Failed to register for remote notifications: \(error)")
    }
}
