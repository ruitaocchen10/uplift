//
//  SearchButton.swift
//  uplift
//
//  Purpose: Circular button with magnifying glass icon for search actions
//  Used in: HomeView, ProgressView, AddExerciseSheet
//

import SwiftUI

/// A circular button with a search icon
/// 
/// Usage:
/// ```swift
/// SearchButton {
///     // Handle search action
///     showingSearch = true
/// }
/// ```
struct SearchButton: View {
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            ZStack {
                Image(systemName: "magnifyingglass")
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
        
        SearchButton {
            print("Search tapped")
        }
    }
}
