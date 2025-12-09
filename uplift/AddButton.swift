//
//  AddButton.swift
//  uplift
//
//  Purpose: Circular button with plus icon for add/create actions
//  Used in: TemplatesView
//

import SwiftUI

/// A circular button with a plus icon for adding/creating items
/// 
/// Usage:
/// ```swift
/// AddButton {
///     showingCreateTemplate = true
/// }
/// ```
struct AddButton: View {
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            ZStack {
                Image(systemName: "plus")
                    .foregroundColor(.white)
                    .font(.futuraBody())
            }
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    ZStack {
        Color.black.ignoresSafeArea()
        
        AddButton {
            print("Add tapped")
        }
    }
}
