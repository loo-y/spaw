//
//  ContentView.swift
//  spaw
//
//  Created by Loo on 2024/10/2.
//

import SwiftUI
import SwiftData
import SwiftUI

struct ContentView: View {
    @EnvironmentObject var notificationService: NotificationService
    @Query private var messages: [Message]
    @State private var simulatedMessage: String = ""
    @Environment(\.modelContext) private var modelContext
    
    var body: some View {
        VStack {
            List(messages) { message in
                Text(message.content)
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
        .onAppear {
            notificationService.requestAuthorization()
        }
    }
}


// #Preview {
//     let container = try! ModelContainer(for: Message.self, configurations: ModelConfiguration(isStoredInMemoryOnly: true))
//     let context = container.mainContext
//     let notificationService = NotificationService(modelContext: context)
    
//     return ContentView()
//         .modelContainer(container)
//         .environmentObject(notificationService)
// }
