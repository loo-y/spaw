//
//  SettingsView.swift
//  spaw
//
//  Created by Loo on 2024/10/2.
//

import SwiftUI

struct SettingsView: View {
    @AppStorage("serverURL") private var serverURL = ""
    @AppStorage("userToken") private var userToken = ""
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Server Configuration")) {
                    TextField("Server URL", text: $serverURL)
                    TextField("User Token", text: $userToken)
                }
                
                Section {
                    Button("Save") {
                        // Here you would typically validate and save the settings
                        print("Settings saved")
                    }
                }
            }
            .navigationTitle("Settings")
        }
    }
}
