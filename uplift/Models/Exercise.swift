//
//  Exercise.swift
//  uplift
//
//  Created by Ruitao Chen on 12/3/25.
//

import Foundation

struct Exercise: Identifiable, Codable {
    let id: UUID
    var name: String
    var sets: [WorkoutSet]
    var isExpanded: Bool // For the expandable UI in your design
    
    init(id: UUID = UUID(), name: String, sets: [WorkoutSet] = [], isExpanded: Bool = false) {
        self.id = id
        self.name = name
        self.sets = sets
        self.isExpanded = isExpanded
    }
    
    // Helper computed properties
    var totalSets: Int {
        sets.count
    }
    
    var totalVolume: Double {
        sets.reduce(0) { $0 + ($1.weight * Double($1.reps)) }
    }
}
