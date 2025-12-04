//
//  WorkoutSet.swift
//  uplift
//
//  Created by Ruitao Chen on 12/3/25.
//

import Foundation

struct WorkoutSet: Identifiable {
    let id = UUID()
    var weight: Double
    var reps: Int
    var isCompleted: Bool
    
    init(weight: Double = 0, reps: Int = 0, isCompleted: Bool = false) {
        self.weight = weight
        self.reps = reps
        self.isCompleted = isCompleted
    }
}
