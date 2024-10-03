//
//  UserSettings.swift
//  spaw
//
//  Created by Loo on 2024/10/3.
//

import Foundation
import SwiftData


@Model
final class UserSettings {
    var notificationEnabled: Bool = true
    var darkMode: Bool = false
    var deviceToken: String = ""
    var serverURL: String = ""
    var userToken: String = ""

    init(notificationEnabled: Bool = true, darkMode: Bool = false, deviceToken: String = "", serverURL: String = "", userToken: String = "") {
        self.notificationEnabled = notificationEnabled
        self.darkMode = darkMode
        self.deviceToken = deviceToken
        self.serverURL = serverURL
        self.userToken = userToken
    }

    func setDeviceToken(_ token: String) {
        self.deviceToken = token
    }

    func getDeviceToken() -> String {
        return self.deviceToken
    }
}
