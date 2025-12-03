//
//  WorkoutSet.swift
//  uplift
//
//  Created by Ruitao Chen on 12/3/25.
//
import Foundation

struct WorkoutSet: Identifiable, Codable {
    let id: UUID
    var weight: Double // in lbs
    var reps: Int
    var isCompleted: Bool
    
    init(id: UUID = UUID(), weight: Double = 0, reps: Int = 0, isCompleted: Bool = false) {
        self.id = id
        self.weight = weight
        self.reps = reps
        self.isCompleted = isCompleted
    }
}
