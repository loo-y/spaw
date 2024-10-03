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
//    @Query private var messages: [Message]
//    @State private var simulatedMessage: String = ""
//    @Environment(\.modelContext) private var modelContext
    
    var body: some View {
        TabView {
            MessageListView()
            .tabItem {
                Label("Messages", systemImage: "message")
            }
            
            SettingsView()
            .tabItem {
                Label("Settings", systemImage: "gear")
            }
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

extension View {
    func dismissKeyboardOnTap() -> some View {
        modifier(DismissKeyboardOnTap())
    }
}
