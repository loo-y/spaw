//
//  PersistenceController.swift
//  spaw
//
//  Created by Loo on 2024/10/2.
//

import SwiftData

class PersistenceController {
    static let shared = PersistenceController()

    let container: ModelContainer

    init() {
        container = try! ModelContainer(for: Schema([Message.self]))
    }
}
