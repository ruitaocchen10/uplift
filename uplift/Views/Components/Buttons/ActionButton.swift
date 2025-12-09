//
//  ActionButton.swift
//  uplift
//
//  Purpose: Reusable full-width action button with multiple styles, icon support, and loading state
//  Used throughout the app for primary and secondary actions
//

import SwiftUI

/// A versatile action button component with support for icons, loading states, and multiple styles
///
/// Usage:
/// ```swift
/// // Primary button
/// ActionButton(
///     title: "Finish Workout",
///     style: .primary
/// ) {
///     finishWorkout()
/// }
///
/// // Secondary with icon
/// ActionButton(
///     title: "Add Workout",
///     icon: "plus.circle",
///     style: .secondary
/// ) {
///     addWorkout()
/// }
///
/// // Loading state
/// ActionButton(
///     title: "Saving...",
///     style: .primary,
///     isLoading: true
/// ) {
///     save()
/// }
/// ```
struct ActionButton: View {
    let title: String
    let icon: String?
    let iconPosition: IconPosition
    let style: ActionButtonStyle
    let isEnabled: Bool
    let isLoading: Bool
    let action: () -> Void
    
    init(
        title: String,
        icon: String? = nil,
        iconPosition: IconPosition = .leading,
        style: ActionButtonStyle,
        isEnabled: Bool = true,
        isLoading: Bool = false,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.icon = icon
        self.iconPosition = iconPosition
        self.style = style
        self.isEnabled = isEnabled
        self.isLoading = isLoading
        self.action = action
    }
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                if isLoading {
                    ProgressView()
                        .tint(style.foregroundColor)
                } else {
                    // Leading icon
                    if iconPosition == .leading, let icon = icon {
                        Image(systemName: icon)
                            .font(.futuraTitle3())
                    }
                    
                    Text(title)
                        .font(.futuraHeadline())
                    
                    // Trailing icon
                    if iconPosition == .trailing, let icon = icon {
                        Image(systemName: icon)
                            .font(.futuraTitle3())
                    }
                }
            }
            .foregroundColor(style.foregroundColor)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(style.background)
            .overlay(style.overlay)
        }
        .disabled(!isEnabled || isLoading)
        .opacity((isEnabled && !isLoading) ? 1.0 : 0.5)
    }
}

// MARK: - Supporting Types

enum ActionButtonStyle {
    case primary
    case secondary
    case tertiary
    
    var foregroundColor: Color {
        switch self {
        case .primary:
            return .black
        case .secondary, .tertiary:
            return .white
        }
    }
    
    var background: some View {
        Group {
            switch self {
            case .primary:
                Capsule()
                    .fill(Color.white)
            case .secondary:
                Capsule()
                    .fill(Color.gray.opacity(0.15))
            case .tertiary:
                Capsule()
                    .fill(Color.clear)
            }
        }
    }
    
    var overlay: some View {
        Group {
            switch self {
            case .primary:
                Capsule()
                    .stroke(Color.clear, lineWidth: 0)
            case .secondary, .tertiary:
                Capsule()
                    .stroke(Color.gray.opacity(0.3), lineWidth: 1)
            }
        }
    }
}

enum IconPosition {
    case leading
    case trailing
}

// MARK: - Previews

#Preview("Primary - Enabled") {
    ZStack {
        Color.black.ignoresSafeArea()
        
        VStack(spacing: 20) {
            ActionButton(
                title: "Finish Workout",
                style: .primary
            ) {
                print("Primary tapped")
            }
            .padding(.horizontal)
        }
    }
}

#Preview("Primary - Loading") {
    ZStack {
        Color.black.ignoresSafeArea()
        
        VStack(spacing: 20) {
            ActionButton(
                title: "Saving...",
                style: .primary,
                isLoading: true
            ) {
                print("Loading")
            }
            .padding(.horizontal)
        }
    }
}

#Preview("Primary - Disabled") {
    ZStack {
        Color.black.ignoresSafeArea()
        
        VStack(spacing: 20) {
            ActionButton(
                title: "Submit",
                style: .primary,
                isEnabled: false
            ) {
                print("Disabled")
            }
            .padding(.horizontal)
        }
    }
}

#Preview("Secondary - Leading Icon") {
    ZStack {
        Color.black.ignoresSafeArea()
        
        VStack(spacing: 20) {
            ActionButton(
                title: "Add Workout",
                icon: "plus.circle",
                iconPosition: .leading,
                style: .secondary
            ) {
                print("Secondary tapped")
            }
            .padding(.horizontal)
        }
    }
}

#Preview("Secondary - Trailing Icon") {
    ZStack {
        Color.black.ignoresSafeArea()
        
        VStack(spacing: 20) {
            ActionButton(
                title: "Continue",
                icon: "arrow.right",
                iconPosition: .trailing,
                style: .secondary
            ) {
                print("Continue tapped")
            }
            .padding(.horizontal)
        }
    }
}

#Preview("Tertiary - Outline") {
    ZStack {
        Color.black.ignoresSafeArea()
        
        VStack(spacing: 20) {
            ActionButton(
                title: "Cancel",
                style: .tertiary
            ) {
                print("Tertiary tapped")
            }
            .padding(.horizontal)
        }
    }
}

#Preview("All Styles") {
    ZStack {
        Color.black.ignoresSafeArea()
        
        VStack(spacing: 20) {
            ActionButton(
                title: "Primary Button",
                style: .primary
            ) {
                print("Primary")
            }
            
            ActionButton(
                title: "Secondary Button",
                icon: "plus.circle",
                style: .secondary
            ) {
                print("Secondary")
            }
            
            ActionButton(
                title: "Tertiary Button",
                style: .tertiary
            ) {
                print("Tertiary")
            }
        }
        .padding(.horizontal)
    }
}
