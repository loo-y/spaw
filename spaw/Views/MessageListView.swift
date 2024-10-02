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
    
    var body: some View {
        VStack {
            List(messages.sorted(by: { $0.receivedDate > $1.receivedDate })) { message in
                VStack(alignment: .leading) {
                    Text(message.content)
                    Text(message.receivedDate.formatted(.dateTime.year().month().day().hour().minute().second()))
                        .font(.caption)
                        .foregroundColor(.gray)
                        .padding(.top, 3)
                }
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
//        .onAppear {
//            notificationService.requestAuthorization()
//        }
    }
    
}

#Preview {
    MessageListView()
}
