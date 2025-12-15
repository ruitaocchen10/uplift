//
//  DataPoint.swift
//  uplift
//
//  Created by Ruitao Chen on 12/15/25.
//

import Foundation

struct DataPoint: Identifiable {
    let id = UUID()
    let date: Date
    let value: Double
}
