//
//  WorkoutSession.swift
//  uplift
//
//  Created by Ruitao Chen on 12/3/25.
//

import Foundation

struct WorkoutSession: Identifiable {
    let id = UUID()
    var templateName: String?
    var date: Date
    var exercises: [Exercise]
    var isCompleted: Bool
    var notes: String?
    
    init(
        templateName: String? = nil,
        date: Date = Date(),
        exercises: [Exercise] = [],
        isCompleted: Bool = false,
        notes: String? = nil
    ) {
        self.templateName = templateName
        self.date = date
        self.exercises = exercises
        self.isCompleted = isCompleted
        self.notes = notes
    }
    
    // UI helper properties
    var totalVolume: Double {
        exercises.reduce(0) { $0 + $1.totalVolume }
    }
    
    var totalSets: Int {
        exercises.reduce(0) { $0 + $1.totalSets }
    }
    
    var completedSets: Int {
        exercises.reduce(0) { total, exercise in
            total + exercise.completedSetsCount
        }
    }
    
    var progressPercentage: Double {
        guard totalSets > 0 else { return 0 }
        return Double(completedSets) / Double(totalSets)
    }
    
    // Initialize from a template
    static func fromTemplate(_ template: WorkoutTemplate) -> WorkoutSession {
        let exercises = template.exercises.map { templateExercise in
            let sets = (0..<templateExercise.targetSets).map { _ in
                WorkoutSet()
            }
            return Exercise(
                name: templateExercise.name,
                sets: sets
            )
        }
        
        return WorkoutSession(
            templateName: template.name,
            date: Date(),
            exercises: exercises
        )
    }
}
