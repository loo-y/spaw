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
    private var application: UIApplication? // 添加 application 属性
    
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
        super.init()
        print("NotificationService 初始化")
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
                self?.setNotificationSettings()
            } else {
                print("通知权限被拒绝")
            }
        }
    }

    func setNotificationSettings(){
        let copyAction = UNNotificationAction(identifier: "copy_action", title: "复制", options: [])
        // let declineAction = UNNotificationAction(identifier: "decline_action", title: "拒绝", options: [])
        let category = UNNotificationCategory(identifier: "QUICK_ACTIONS_CATEGORY", actions: [copyAction], intentIdentifiers: [], options: [])

        UNUserNotificationCenter.current().setNotificationCategories([category])
        print("setNotificationSettings")
    }
    
    func getNotificationSettings() {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            print("Notification settings: \(settings)")
            DispatchQueue.main.async {
                UIApplication.shared.registerForRemoteNotifications()
                print("registerForRemoteNotifications")
            }
        }
    }
    
    func registerDeviceToken(_ deviceToken: Data, application: UIApplication) {
        self.application = application;
        let tokenParts = deviceToken.map { data in String(format: "%02.2hhx", data) }
        let token = tokenParts.joined()
        print("DeviceToken: \(token)")
        
        // 保存设备令牌到 SwiftData
        let fetchDescriptor = FetchDescriptor<UserSettings>()
        do {
            let existingSettings = try self.modelContext.fetch(fetchDescriptor)
            if let settings = existingSettings.last {
                settings.setDeviceToken(token)
            } else {
                let newSettings = UserSettings(deviceToken: token)
                self.modelContext.insert(newSettings)
                print("no existingSettings")
            }
            try self.modelContext.save()
            print("设备令牌已保存到 SwiftData")
        } catch {
            print("保存设备令牌时出错: \(error)")
        }

        // 这里你应该将 token 发送到你的服务器
    }
    
    private var lastHandledNotificationId: String?
    private var isHandlingNotification = false

    // 处理收到的推送通知
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        
        // 当在app内时，这个方法会被执行2次，不知道是什么原因
        // 为了避免重复，设定 notificationId 和 isHandlingNotification
        let notificationId = notification.request.identifier

        // 检查是否正在处理通知
        guard !isHandlingNotification else {
            print("正在处理通知，跳过重复调用")
            completionHandler([])
            return
        }
        
        // 检查是否是重复的通知
        guard notificationId != lastHandledNotificationId else {
            print("重复的通知，跳过处理")
            completionHandler([])
            return
        }

        isHandlingNotification = true
        lastHandledNotificationId = notificationId

        let userInfo = notification.request.content.userInfo
        print("Received notification: \(userInfo)")
        // 获取推送的消息内容
        if let aps = userInfo["aps"] as? [String: Any],
           let alert = aps["alert"] as? String {
            print("推送消息内容 alert: \(alert)")
            DispatchQueue.main.async {
                self.lastMessage = alert
                let newMessage = Message(title: "测试消息", content: alert, receivedDate: Date())
                // 将新消息保存到SwiftData
                self.modelContext.insert(newMessage)
                
                do {
                    try self.modelContext.save()
                    print("content:\(newMessage.content)")
                    
                } catch {
                    print("Error saving message: \(error)")
                }
            }
        } else if let message = userInfo["message"] as? String {
            print("推送消息内容message: \(message)")
            DispatchQueue.main.async {
                self.lastMessage = message
                let newMessage = Message(title: "测试消息", content: message, receivedDate: Date())
                // 将新消息保存到SwiftData
                self.modelContext.insert(newMessage)
                
                do {
                    try self.modelContext.save()
                    print("content:\(newMessage.content)")
                    
                } catch {
                    print("Error saving message: \(error)")
                }
            }
        } else {
            print("无法解析推送消息内容")
        }
        
        isHandlingNotification = false
        
        // 允许通知在前台显示
        completionHandler([.banner, .sound])
    }
    
    // 处理用户点击通知的响应
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse,
                                withCompletionHandler completionHandler: @escaping () -> Void) {
        let userInfo = response.notification.request.content.userInfo
        let category = response.notification.request.content.categoryIdentifier
        let actionIdentifier = response.actionIdentifier
        print("Responded to notification: \(userInfo)")
        print("category: \(category)")
        print("actionIdentifier: \(actionIdentifier)")
//        let application = (UIApplication.shared.delegate as! AppDelegate).application // 获取 application 对象
        
        // 这里可以添加处理用户点击通知的逻辑
        if category == "QUICK_ACTIONS_CATEGORY" {
            switch actionIdentifier {
                case "copy_action":
                    // 处理接受操作
                    print("copy_action");

    //                if let url = URL(string: "spaw://") { // 替换为你的 app scheme
    //                    application?.open(url) { success in
    //                        if !success {
    //                            // 处理打开失败的情况
    //                            print("open failed")
    //                        }else {
    //                            if let aps = userInfo["aps"] as? [String: Any],
    //                               let alert = aps["alert"] as? String {
    //                                print("推送消息内容 alert: \(alert)")
    //                                CommonUtil.copyToClipboard(content: alert)
    //                            }
    //                        }
    //                    }
    //                }
    //                break;
                case "decline_action":
                    // 处理拒绝操作
                    print("decline_action");
                    break;
                case UNNotificationDefaultActionIdentifier: // 用户点击了通知本身
                    // 处理默认操作，例如打开应用
                    print("UNNotificationDefaultActionIdentifier: \(UNNotificationDefaultActionIdentifier)")
                    break;
                default:
                    print("default")
                    break
            }
        }
        
        if let aps = userInfo["aps"] as? [String: Any],
           let alert = aps["alert"] as? String {
            print("推送消息内容 alert: \(alert)")
            CommonUtil.copyToClipboard(content: alert)
        }
        print("completionHandler")
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
