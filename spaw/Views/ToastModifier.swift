//
//  ToastModifier.swift
//  spaw
//
//  Created by Loo on 2024/10/3.
//

import SwiftUI

struct ToastModifier<ToastContent: View>: ViewModifier {
    @Binding var isPresented: Bool
    let toastContent: () -> ToastContent
    let duration: Double
    
    @State private var workItem: DispatchWorkItem?
    
    func body(content: Content) -> some View {
        content
            .overlay(
                ZStack {
                    if isPresented {
                        toastContent()
                            .transition(.opacity)
                    }
                }
            )
            .onChange(of: isPresented) { newValue in
                if newValue {
                    showToast()
                } else {
                    workItem?.cancel()
                }
            }
    }
    
    private func showToast() {
        workItem?.cancel()
        
        let task = DispatchWorkItem {
            withAnimation {
                isPresented = false
            }
        }
        workItem = task
        DispatchQueue.main.asyncAfter(deadline: .now() + duration, execute: task)
    }
}
