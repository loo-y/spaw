//
//  MessageListView.swift
//  spaw
//
//  Created by Loo on 2024/10/2.
//

import SwiftUI
import SwiftData

struct MessageListView: View {
    @Environment(\.modelContext) private var modelContext
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
        NavigationView {
        VStack {
            List {
                ForEach(messages.sorted(by: { $0.receivedDate > $1.receivedDate })) { message in
                    HStack { // 使用 HStack 包裹 VStack
                        VStack(alignment: .leading) {
                            Text(message.content)
                                .padding(.leading, 16)
                                .padding(.top, 8)
                            Text(message.receivedDate.formatted(.dateTime.year().month().day().hour().minute().second()))
                                .font(.caption)
                                .foregroundColor(.gray)
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
                .onDelete { indexSet in
                    for index in indexSet {
                        let messageToDelete = messages.sorted(by: { $0.receivedDate > $1.receivedDate })[index]
                        // 这里需要添加删除消息的逻辑，例如：
                        modelContext.delete(messageToDelete)
                        do {
                            try self.modelContext.save()
                            
                        } catch {
                            print("Error saving message: \(error)")
                        }
                    }
                }
            }
            .listStyle(PlainListStyle())
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
        .navigationTitle("消息")
        }
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
