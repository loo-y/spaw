//
//  CommonUtil.swift
//  spaw
//
//  Created by Loo on 2024/10/2.
//

import Foundation
import SwiftUI

class CommonUtil {
    static func copyToClipboard(content: String) {
        UIPasteboard.general.string = content
        print("copyToClipboard: \(content)")
    }
}
