//
//  Item.swift
//  spaw
//
//  Created by Loo on 2024/10/2.
//

import Foundation
import SwiftData

@Model
final class Message {
    var id: UUID
    var title: String
    var content: String
    var receivedDate: Date
    
    init(id: UUID = UUID(), title: String, content: String, receivedDate: Date = Date()) {
        self.id = id
        self.title = title
        self.content = content
        self.receivedDate = receivedDate
    }
}