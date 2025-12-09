//
//  CancelButton.swift
//  uplift
//
//  Purpose: Text button for cancel/dismiss actions
//  Used in: CreateEditTemplateView, AddTemplateExerciseSheet, ConfigureExerciseSheet, and all modal sheets
//

import SwiftUI

/// A text button that displays "Cancel"
/// 
/// Usage:
/// ```swift
/// CancelButton {
///     dismiss()
/// }
/// ```
struct CancelButton: View {
    let action: () -> Void
    
    var body: some View {
        Button("Cancel", action: action)
            .font(.futuraBody())
            .foregroundColor(.white)
    }
}

#Preview {
    ZStack {
        Color.black.ignoresSafeArea()
        
        CancelButton {
            print("Cancel tapped")
        }
    }
}
