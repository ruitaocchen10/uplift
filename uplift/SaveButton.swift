//
//  SaveButton.swift
//  uplift
//
//  Purpose: Text button for save actions with enabled/disabled state
//  Used in: CreateEditTemplateView, ConfigureExerciseSheet, EditTemplateExerciseSheet
//

import SwiftUI

/// A text button that displays "Save" with enabled/disabled styling
/// 
/// Usage:
/// ```swift
/// SaveButton(enabled: isValid) {
///     saveTemplate()
/// }
/// ```
struct SaveButton: View {
    let enabled: Bool
    let action: () -> Void
    
    var body: some View {
        Button("Save", action: action)
            .font(.futuraBody())
            .foregroundColor(enabled ? .white : .gray)
            .disabled(!enabled)
    }
}

#Preview("Enabled") {
    ZStack {
        Color.black.ignoresSafeArea()
        
        SaveButton(enabled: true) {
            print("Save tapped")
        }
    }
}

#Preview("Disabled") {
    ZStack {
        Color.black.ignoresSafeArea()
        
        SaveButton(enabled: false) {
            print("This won't fire")
        }
    }
}
