//
//  DoneButton.swift
//  uplift
//
//  Purpose: Text button for done/dismiss actions
//  Used in: FullCalendarPicker, WorkoutDetailSheet, and other modal sheets
//

import SwiftUI

/// A text button that displays "Done"
/// 
/// Usage:
/// ```swift
/// DoneButton {
///     dismiss()
/// }
/// ```
struct DoneButton: View {
    let action: () -> Void
    
    var body: some View {
        Button("Done", action: action)
            .font(.futuraBody())
            .foregroundColor(.white)
    }
}

#Preview {
    ZStack {
        Color.black.ignoresSafeArea()
        
        DoneButton {
            print("Done tapped")
        }
    }
}
