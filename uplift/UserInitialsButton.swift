//
//  UserInitialsButton.swift
//  uplift
//
//  Purpose: Circular button displaying user initials
//  Used in: HomeView, TemplatesView, ProgressView (main tab views)
//

import SwiftUI

/// A circular button that displays user initials
/// 
/// Usage:
/// ```swift
/// UserInitialsButton(initials: "RC", action: { 
///     // Optional: Navigate to profile
/// })
/// 
/// // Or without action (just display)
/// UserInitialsButton(initials: "RC", action: nil)
/// ```
struct UserInitialsButton: View {
    let initials: String
    let action: (() -> Void)?
    
    init(initials: String, action: (() -> Void)? = nil) {
        self.initials = initials
        self.action = action
    }
    
    var body: some View {
        Button(action: {
            action?()
        }) {
            ZStack {
                Text(initials)
                    .font(.futuraHeadline())
                    .foregroundColor(.white)
            }
        }
        .disabled(action == nil)
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview("With Action") {
    ZStack {
        Color.black.ignoresSafeArea()
        
        UserInitialsButton(initials: "RC") {
            print("Profile tapped")
        }
    }
}

#Preview("Display Only") {
    ZStack {
        Color.black.ignoresSafeArea()
        
        UserInitialsButton(initials: "RC", action: nil)
    }
}
