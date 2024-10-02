//
//  Item.swift
//  spaw
//
//  Created by Loo on 2024/10/2.
//

import Foundation
import SwiftData

@Model
final class Item {
    var timestamp: Date
    
    init(timestamp: Date) {
        self.timestamp = timestamp
    }
}
