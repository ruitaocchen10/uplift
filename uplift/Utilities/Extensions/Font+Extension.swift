//
//  Font+Extensions.swift
//  uplift
//
//  Created by Ruitao Chen on 12/3/25.
//

import SwiftUI

extension Font {
    // MARK: - Futura Font Styles
    
    // Display/Title styles
    static func futuraLargeTitle() -> Font {
        return .custom("Futura-Medium", size: 34)
    }
    
    static func futuraTitle() -> Font {
        return .custom("Futura-Medium", size: 28)
    }
    
    static func futuraTitle2() -> Font {
        return .custom("Futura-Medium", size: 22)
    }
    
    static func futuraTitle3() -> Font {
        return .custom("Futura-Medium", size: 20)
    }
    
    // Body/Content styles
    static func futuraHeadline() -> Font {
        return .custom("Futura-Medium", size: 17)
    }
    
    static func futuraBody() -> Font {
        return .custom("Futura-Medium", size: 17)
    }
    
    static func futuraCallout() -> Font {
        return .custom("Futura-Medium", size: 16)
    }
    
    static func futuraSubheadline() -> Font {
        return .custom("Futura-Medium", size: 15)
    }
    
    static func futuraFootnote() -> Font {
        return .custom("Futura-Medium", size: 13)
    }
    
    static func futuraCaption() -> Font {
        return .custom("Futura-Medium", size: 12)
    }
    
    static func futuraCaption2() -> Font {
        return .custom("Futura-Medium", size: 11)
    }
    
    // MARK: - Bold variants
    
    static func futuraBold(size: CGFloat = 17) -> Font {
        return .custom("Futura-Bold", size: size)
    }
    
    static func futuraMedium(size: CGFloat = 17) -> Font {
        return .custom("Futura-Medium", size: size)
    }
}
