//
//  WorkoutTemplate.swift
//  uplift
//
//  Created by Ruitao Chen on 12/3/25.
//

import Foundation
import SwiftData

@Model
class WorkoutTemplate {
    @Attribute(.unique) var id: UUID
    var name: String
    @Relationship(deleteRule: .cascade) var exercises: [TemplateExercise]
    
    init(name: String, exercises: [TemplateExercise] = []) {
        self.id = UUID()
        self.name = name
        self.exercises = exercises
    }
    
    // UI helper properties
    var totalExercises: Int {
        exercises.count
    }
    
    var estimatedDuration: Int {
        // Rough estimate: 3 minutes per set + 2 minutes per exercise for transitions
        let totalSets = exercises.reduce(0) { $0 + $1.targetSets }
        return (totalSets * 3) + (exercises.count * 2)
    }
}

@Model
class TemplateExercise {
    @Attribute(.unique) var id: UUID
    var name: String
    var targetSets: Int
    var targetRepsMin: Int
    var targetRepsMax: Int
    var notes: String?
    
    init(name: String, targetSets: Int, targetRepsMin: Int, targetRepsMax: Int, notes: String? = nil) {
        self.id = UUID()
        self.name = name
        self.targetSets = targetSets
        self.targetRepsMin = targetRepsMin
        self.targetRepsMax = targetRepsMax
        self.notes = notes
    }
    
    var targetRepsDisplay: String {
        if targetRepsMin == targetRepsMax {
            return "\(targetRepsMin)"
        } else {
            return "\(targetRepsMin)-\(targetRepsMax)"
        }
    }
    
    var displayString: String {
        return "\(targetSets) sets x \(targetRepsDisplay) reps"
    }
}
