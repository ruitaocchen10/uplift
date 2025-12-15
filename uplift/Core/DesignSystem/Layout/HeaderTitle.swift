//
//  HeaderTitle.swift
//  uplift
//
//  Purpose: Displays single or double-line title for toolbar principal placement
//  Used in: HomeView, TemplatesView, ProgressView, and any view needing custom title styling
//

import SwiftUI

/// A title component that can display either a single title or title with subtitle
/// Designed for use in toolbar's principal placement
/// 
/// Usage:
/// ```swift
/// // Single line title
/// HeaderTitle(title: "Templates")
/// 
/// // Double line with subtitle
/// HeaderTitle(
///     title: "Ruitao Chen",
///     subtitle: "Welcome back"
/// )
/// ```
struct HeaderTitle: View {
    let title: String
    let subtitle: String?
    let titleFont: Font
    let subtitleFont: Font
    
    init(
        title: String,
        subtitle: String? = nil,
        titleFont: Font = .futuraHeadline(),
        subtitleFont: Font = .futuraFootnote()
    ) {
        self.title = title
        self.subtitle = subtitle
        self.titleFont = titleFont
        self.subtitleFont = subtitleFont
    }
    
    var body: some View {
        VStack(spacing: 2) {
            if let subtitle = subtitle {
                Text(subtitle)
                    .font(subtitleFont)
                    .foregroundColor(.gray)
            }
            
            Text(title)
                .font(titleFont)
                .fontWeight(.medium)
                .foregroundColor(.white)
        }
    }
}

#Preview("Single Line") {
    ZStack {
        Color.black.ignoresSafeArea()
        
        HeaderTitle(title: "Templates")
    }
}

#Preview("Double Line") {
    ZStack {
        Color.black.ignoresSafeArea()
        
        HeaderTitle(
            title: "Ruitao Chen",
            subtitle: "Welcome back"
        )
    }
}
