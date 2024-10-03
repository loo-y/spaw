//
//  MessageListView.swift
//  spaw
//
//  Created by Loo on 2024/10/2.
//

import SwiftUI
import SwiftData
import SwiftUI

struct MessageListView: View {
    @EnvironmentObject var notificationService: NotificationService
    @Query private var messages: [Message]
    @State private var simulatedMessage: String = ""
    @State private var selectedContent: String? = nil
    @State private var showToast: Bool = false
    
    private func copyToClipboard(content: String) {
        UIPasteboard.general.string = content
        showToast = true
    }

    var body: some View {
        VStack {
            List(messages.sorted(by: { $0.receivedDate > $1.receivedDate })) { message in
                HStack { // 使用 HStack 包裹 VStack
                    VStack(alignment: .leading) {
                        Text(message.content)
                            .padding(.leading, 16)
                            .padding(.top, 8)
                        Text(message.receivedDate.formatted(.dateTime.year().month().day().hour().minute().second()))
                            .font(.caption)
                            .foregroundColor(.gray)
//                            .padding(.top, 1)
                            .padding(.leading, 16) // 保持文本的左侧填充一致
                        Text(" ")
                            .padding(.bottom, -16) // 添加一个空白Text，否则最底部的分割线会跟随上面的文字一起padding
                    }
                    .listRowInsets(EdgeInsets()) // 移除默认行内边距
                    Spacer()  // 使用 Spacer 将 VStack 内容推到左侧
                }
//                .frame(maxWidth: .infinity)
                .contentShape(Rectangle())  // 使整个VStack区域都可以响应点击
                .listRowInsets(EdgeInsets())  // 移除默认行内边距
                .onTapGesture {
                    print("clicked")
                    copyToClipboard(content: message.content)
                }
                
            }
            .toast(isPresented: $showToast, duration: 1.0) {
                // TODO 当连续点击的时候，toast的内容没有消失
                Text("内容已复制")
                    .padding()
                    .background(Color.black.opacity(0.7))
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
            if let lastMessage = notificationService.lastMessage {
                Text("最新通知: \(lastMessage)")
                    .padding()
                    .background(Color.yellow.opacity(0.3))
                    .cornerRadius(10)
            }
            HStack {
                TextField("输入模拟消息", text: $simulatedMessage)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                
                Button("发送模拟消息") {
                    if !simulatedMessage.isEmpty {
                        notificationService.simulateMessageReceived(content: simulatedMessage)
                        simulatedMessage = ""
                    }
                }
                .disabled(simulatedMessage.isEmpty)
            }
            .padding()
            
        }
        .contentShape(Rectangle()) // 确保整个视图都能响应点击事件
        .dismissKeyboardOnTap()
//        .simultaneousGesture(
//                TapGesture()
//                    .onEnded {
//                        print("Parent tapped")
//                        hideKeyboard() // 点击空白处隐藏键盘
//                    }
//            )
//        .onTapGesture {
//            hideKeyboard() // 点击空白处隐藏键盘
//        }
//        .padding(.leading, 8)
//        .padding(.trailing, 8)
//        .onAppear {
//            notificationService.requestAuthorization()
//        }
    }
    
}

#Preview {
    MessageListView()
}

extension View {
    func toast<Content: View>(
        isPresented: Binding<Bool>,
        duration: Double = 2.0,
        @ViewBuilder content: @escaping () -> Content
    ) -> some View {
        modifier(ToastModifier(isPresented: isPresented, toastContent: content, duration: duration))
    }
}
