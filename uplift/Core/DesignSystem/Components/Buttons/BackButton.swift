//
//  BackButton.swift
//  uplift
//
//  Purpose: Chevron left button for back navigation
//  Used in: ExerciseDetailView, WorkoutLoggingView
//

import SwiftUI

/// A button with chevron left icon for back navigation
/// 
/// Usage:
/// ```swift
/// BackButton {
///     dismiss()
/// }
/// ```
struct BackButton: View {
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Image(systemName: "chevron.left")
                .font(.futuraTitle3())
                .foregroundColor(.white)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    ZStack {
        Color.black.ignoresSafeArea()
        
        BackButton {
            print("Back tapped")
        }
    }
}
