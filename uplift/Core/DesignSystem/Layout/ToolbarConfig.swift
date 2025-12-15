//
//  ToolbarConfig.swift
//  uplift
//
//  Purpose: Helper extensions and modifiers for consistent toolbar styling
//  Used in: All views with custom toolbars
//

import SwiftUI

// MARK: - View Extension for Standard Toolbar Styling

extension View {
    /// Applies the standard app toolbar styling (black background, visible)
    ///
    /// Usage:
    /// ```swift
    /// NavigationStack {
    ///     ContentView()
    ///         .standardToolbar()
    /// }
    /// ```
    func standardToolbar() -> some View {
        self
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbarBackground(Color.black, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
    }
    
    /// Applies transparent toolbar styling
    ///
    /// Usage:
    /// ```swift
    /// NavigationStack {
    ///     ContentView()
    ///         .transparentToolbar()
    /// }
    /// ```
    func transparentToolbar() -> some View {
        self
            .toolbarBackground(.hidden, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
    }
    
    /// Applies custom colored toolbar styling
    ///
    /// Usage:
    /// ```swift
    /// NavigationStack {
    ///     ContentView()
    ///         .coloredToolbar(.blue)
    /// }
    /// ```
    func coloredToolbar(_ color: Color) -> some View {
        self
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbarBackground(color, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
    }
}

#Preview("Standard Toolbar") {
    NavigationStack {
        ZStack {
            Color.black.ignoresSafeArea()
            
            Text("Standard Black Toolbar")
                .foregroundColor(.white)
        }
        .toolbar {
            ToolbarItem(placement: .principal) {
                HeaderTitle(title: "Home")
            }
        }
        .standardToolbar()
    }
}
