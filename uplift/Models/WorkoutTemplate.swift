//
//  WorkoutTemplate.swift
//  uplift
//
//  Created by Ruitao Chen on 12/3/25.
//

import Foundation

struct WorkoutTemplate: Identifiable, Codable {
    let id: UUID
    var name: String
    var exercises: [TemplateExercise]
    var createdDate: Date
    var lastUsedDate: Date?
    var notes: String?
    
    init(
        id: UUID = UUID(),
        name: String,
        exercises: [TemplateExercise] = [],
        createdDate: Date = Date(),
        lastUsedDate: Date? = nil,
        notes: String? = nil
    ) {
        self.id = id
        self.name = name
        self.exercises = exercises
        self.createdDate = createdDate
        self.lastUsedDate = lastUsedDate
        self.notes = notes
    }
    
    // Helper computed properties
    var totalExercises: Int {
        exercises.count
    }
    
    var estimatedDuration: Int {
        // Rough estimate: 3 minutes per set + 2 minutes per exercise for transitions
        let totalSets = exercises.reduce(0) { $0 + $1.targetSets }
        return (totalSets * 3) + (exercises.count * 2)
    }
}

// Template exercise structure (prescribed sets/reps, no actual performance data)
struct TemplateExercise: Identifiable, Codable {
    let id: UUID
    var name: String
    var targetSets: Int
    var targetRepsMin: Int
    var targetRepsMax: Int
    var notes: String?
    var order: Int // For maintaining exercise order in template
    
    init(
        id: UUID = UUID(),
        name: String,
        targetSets: Int,
        targetRepsMin: Int,
        targetRepsMax: Int,
        notes: String? = nil,
        order: Int = 0
    ) {
        self.id = id
        self.name = name
        self.targetSets = targetSets
        self.targetRepsMin = targetRepsMin
        self.targetRepsMax = targetRepsMax
        self.notes = notes
        self.order = order
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
