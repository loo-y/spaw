//
//  NotificationService.swift
//  spaw
//
//  Created by Loo on 2024/10/2.
//



import Foundation
import UserNotifications
import SwiftUI
import SwiftData

class NotificationService: NSObject, UNUserNotificationCenterDelegate, ObservableObject {
    @Published var isRegistered: Bool = false
    @Published var lastMessage: String?
//    @Environment(\.modelContext) private var modelContext
    private var modelContext: ModelContext
    
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
        super.init()
        UNUserNotificationCenter.current().delegate = self
    }
    
    func requestAuthorization() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { [weak self] granted, error in
            DispatchQueue.main.async {
                self?.isRegistered = granted
            }
            if granted {
                print("通知权限已授予")
                self?.getNotificationSettings()
            } else {
                print("通知权限被拒绝")
            }
        }
    }
    
    func getNotificationSettings() {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            print("Notification settings: \(settings)")
            DispatchQueue.main.async {
                UIApplication.shared.registerForRemoteNotifications()
            }
        }
    }
    
    func registerDeviceToken(_ deviceToken: Data) {
        let tokenParts = deviceToken.map { data in String(format: "%02.2hhx", data) }
        let token = tokenParts.joined()
        print("Device Token: \(token)")
        // 这里你应该将 token 发送到你的服务器
    }
    
    // 处理收到的推送通知
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        let userInfo = notification.request.content.userInfo
        print("Received notification: \(userInfo)")
        
        // 更新 lastMessage
        if let message = userInfo["message"] as? String {
            DispatchQueue.main.async {
                self.lastMessage = message
            }
        }
        
        // 允许通知在前台显示
        completionHandler([.banner, .sound])
    }
    
    // 处理用户点击通知的响应
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse,
                                withCompletionHandler completionHandler: @escaping () -> Void) {
        let userInfo = response.notification.request.content.userInfo
        print("Responded to notification: \(userInfo)")
        
        // 这里可以添加处理用户点击通知的逻辑
        
        completionHandler()
    }
   
    // 添加这个新方法来模拟接收消息
    func simulateMessageReceived(content: String) {
        // 确保所有UI更新和数据操作都在主线程上执行
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.lastMessage = content
            
            // 创建一个新的Message实例
            let newMessage = Message(title: "测试消息", content: content, receivedDate: Date())
            
            // 将新消息保存到SwiftData
            self.modelContext.insert(newMessage)
            
            do {
                try self.modelContext.save()
                
            } catch {
                print("Error saving message: \(error)")
            }
            
            // 创建一个本地通知
            let notificationContent = UNMutableNotificationContent()
            notificationContent.title = newMessage.title
            notificationContent.body = newMessage.content
            notificationContent.sound = .default

            let request = UNNotificationRequest(identifier: UUID().uuidString, content: notificationContent, trigger: nil)
            UNUserNotificationCenter.current().add(request)
        }
    }
}
