//
//  Exercise.swift
//  uplift
//
//  Created by Ruitao Chen on 12/3/25.
//

import Foundation

struct Exercise: Identifiable {
    let id = UUID()
    var name: String
    var sets: [WorkoutSet]
    var isExpanded: Bool = false
    
    init(name: String, sets: [WorkoutSet] = [], isExpanded: Bool = false) {
        self.name = name
        self.sets = sets
        self.isExpanded = isExpanded
    }
    
    // UI helper properties
    var completedSetsCount: Int {
        sets.filter { $0.isCompleted }.count
    }
    
    var totalSets: Int {
        sets.count
    }
    
    var totalVolume: Double {
        sets.reduce(0) { $0 + ($1.weight * Double($1.reps)) }
    }
}
