//
//  GradientBorder.swift
//  uplift
//
//  Created by Ruitao Chen on 12/5/25.
//

import SwiftUI

// MARK: - Gradient Border Modifier

enum FadeStyle {
    case horizontal  // Fades left and right
    case vertical    // Fades top and bottom
    case radial      // Fades from center outward
}

struct GradientBorderModifier: ViewModifier {
    let cornerRadius: CGFloat
    let lineWidth: CGFloat
    let gradient: LinearGradient
    
    func body(content: Content) -> some View {
        content
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .strokeBorder(gradient, lineWidth: lineWidth)
            )
    }
}

extension View {
    /// Adds a gradient border around the view
    /// - Parameters:
    ///   - gradient: The gradient to use for the border
    ///   - cornerRadius: Corner radius of the border
    ///   - lineWidth: Width of the border line
    func gradientBorder(
        _ gradient: LinearGradient,
        cornerRadius: CGFloat,
        lineWidth: CGFloat = 1
    ) -> some View {
        self.modifier(GradientBorderModifier(
            cornerRadius: cornerRadius,
            lineWidth: lineWidth,
            gradient: gradient
        ))
    }
    
    /// Adds a fade-edge border (strong in middle, fades on sides)
    /// - Parameters:
    ///   - color: Base color for the border
    ///   - cornerRadius: Corner radius of the border
    ///   - lineWidth: Width of the border line
    ///   - fadeStyle: Direction of fade (horizontal or vertical)
    func fadeEdgeBorder(
        color: Color,
        cornerRadius: CGFloat,
        lineWidth: CGFloat = 1,
        fadeStyle: FadeStyle = .horizontal
    ) -> some View {
        let gradient: LinearGradient
        
        switch fadeStyle {
        case .horizontal:
            gradient = LinearGradient(
                colors: [
                    color.opacity(0.0),  // Fade left
                    color.opacity(0.5),
                    color.opacity(1.0),  // Strong middle
                    color.opacity(0.5),
                    color.opacity(0.0)   // Fade right
                ],
                startPoint: .leading,
                endPoint: .trailing
            )
        case .vertical:
            gradient = LinearGradient(
                colors: [
                    color.opacity(0.0),  // Fade top
                    color.opacity(0.5),
                    color.opacity(1.0),  // Strong middle
                    color.opacity(0.5),
                    color.opacity(0.0)   // Fade bottom
                ],
                startPoint: .top,
                endPoint: .bottom
            )
        case .radial:
            // For radial, we'll use a different approach
            return AnyView(
                self.overlay(
                    RoundedRectangle(cornerRadius: cornerRadius)
                        .stroke(
                            RadialGradient(
                                colors: [
                                    color.opacity(1.0),  // Strong center
                                    color.opacity(0.5),
                                    color.opacity(0.0)   // Fade edges
                                ],
                                center: .center,
                                startRadius: 0,
                                endRadius: 100
                            ),
                            lineWidth: lineWidth
                        )
                )
            )
        }
        
        return AnyView(self.gradientBorder(gradient, cornerRadius: cornerRadius, lineWidth: lineWidth))
    }
    
    
}
