//
//  MenuButton.swift
//  uplift
//
//  Purpose: Ellipsis button for menu/options actions
//  Used in: WorkoutLoggingView
//

import SwiftUI

/// A button with ellipsis (three dots) icon for showing menus or options
/// 
/// Usage:
/// ```swift
/// MenuButton {
///     showingMenu = true
/// }
/// ```
struct MenuButton: View {
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Image(systemName: "ellipsis")
                .font(.futuraTitle3())
                .foregroundColor(.white)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    ZStack {
        Color.black.ignoresSafeArea()
        
        MenuButton {
            print("Menu tapped")
        }
    }
}
