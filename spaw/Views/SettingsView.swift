//
//  SettingsView.swift
//  spaw
//
//  Created by Loo on 2024/10/2.
//

import SwiftUI
import SwiftData

struct SettingsView: View {
    @Environment(\.modelContext) private var modelContext
//    @Query private var userSettings: [UserSettings]
    @State private var firstUserSettings: UserSettings?
    @Query private var messages: [Message]
    @AppStorage("serverURL") private var serverURL = ""
    @AppStorage("userToken") private var userToken = ""
    @State private var showingAlert: Bool = false
    @State private var alertMessage: String = ""
    
    var body: some View {
        
        NavigationView {
            Form {
                Section(header: Text("服务器配置")) {
                    TextField("服务器 URL http(s)://ServerHost", text: $serverURL)
                    HStack {
                        TextField("随机用户令牌", text: .constant(userToken))
                            .disabled(true)
                        Text(Image(systemName: "dice"))
                            .foregroundColor(.blue)
                            .onTapGesture {
                                let letters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
                                userToken = String((0..<16).map{ _ in letters.randomElement()! })
                            }
                    }
                }
                
                Section(header: Text("DeviceToken")) {
                    if let deviceToken = firstUserSettings?.deviceToken {
                        Text(deviceToken)
                            .font(.footnote)
                            .foregroundColor(.gray)
                    } else {
                        Text("未获取到设备令牌")
                            .font(.footnote)
                            .foregroundColor(.red)
                    }
                }
                
                Section {
                    HStack{
                        Text("保存") // 使用Text代替Button
                            .padding(4)
                        //                        .background(Color.blue)
                            .foregroundColor(.blue)
                            .cornerRadius(8)
                    
                        Spacer()  // 使用 Spacer 将 Text 内容推到左侧 并且撑满
                    }
//                    .listRowInsets(EdgeInsets())  // 移除默认行内边距
                    .contentShape(Rectangle())  // 使整个HStack区域都可以响应点击
                    .onTapGesture {
                        // 执行按钮逻辑
                        print("Button tapped!")
                        // 这里通常会验证并保存设置
                        if let settings = firstUserSettings {
                            // 保存用户输入的serverURL
                            settings.serverURL = serverURL.trimmingCharacters(in: .whitespacesAndNewlines)
                            print("保存的服务器URL: \(settings.serverURL)")
                            // 保存用户输入的userToken
                            settings.userToken = userToken.trimmingCharacters(in: .whitespacesAndNewlines)
                            print("保存的用户令牌: \(settings.userToken)")
                            do {
                                try self.modelContext.save()
                                print("设置已成功保存到 UserSettings")
                                // 调用 APIService 的 saveToken 方法
                                // 检查所有必要信息是否都存在
                                if !settings.serverURL.isEmpty && !settings.userToken.isEmpty && !settings.deviceToken.isEmpty {
                                    Task {
                                        do {
                                            try await APIService.saveToken(serverUrl: settings.serverURL, userToken: settings.userToken, deviceToken: settings.deviceToken)
                                            print("令牌已成功保存到服务器")
                                        } catch {
                                            print("保存令牌到服务器时出错: \(error)")
                                            // 显示错误弹窗 (方法1：使用alert状态变量)
                                            showingAlert = true
                                            alertMessage = "保存令牌到服务器时出错"
                                        }
                                    }
                                }
                                else {
                                    // 构建缺失信息的提示消息
                                    var missingInfo = [String]()
                                    if settings.serverURL.isEmpty { missingInfo.append("服务器地址") }
                                    if settings.userToken.isEmpty { missingInfo.append("用户令牌") }
                                    if settings.deviceToken.isEmpty { missingInfo.append("设备令牌") }
                                    let message = "缺少以下信息：\(missingInfo.joined(separator: ", "))"
                                    
                                    // 显示错误弹窗 (方法1：使用alert状态变量)
                                    showingAlert = true
                                    alertMessage = message
                                    print(message)
                                }
                            } catch {
                                print("保存设置时出错: \(error)")
                            }
                        } else {
                            print("未找到 UserSettings，无法保存")
                        }
                    }
                }
            }
            .navigationTitle("设置")
        }
        .onAppear {
            Task {
                do {
                    let settings = try await modelContext.fetch(FetchDescriptor<UserSettings>())
                    firstUserSettings = settings.first
                    serverURL = firstUserSettings?.serverURL ?? ""
                    userToken = firstUserSettings?.userToken ?? ""
                } catch {
                    print("Error fetching UserSettings: \(error)")
                }
            }
        }
        .dismissKeyboardOnTap()
        .alert(isPresented: $showingAlert) {
            Alert(title: Text("错误"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
        }
    }
}

