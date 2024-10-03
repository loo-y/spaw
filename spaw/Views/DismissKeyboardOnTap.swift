//
//  DismissKeyboardOnTap.swift
//  spaw
//
//  Created by Loo on 2024/10/3.
//

import SwiftUI

struct DismissKeyboardOnTap: ViewModifier {
    func body(content: Content) -> some View {
        content
            .simultaneousGesture(
                TapGesture()
                    .onEnded { _ in
                        print("parent clicked")
                        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                    }
            )
    }
}
