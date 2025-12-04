//
//  WorkoutSession.swift
//  uplift
//
//  Created by Ruitao Chen on 12/3/25.
//

import Foundation
import SwiftData

@Model
class WorkoutSession {
    @Attribute(.unique) var id: UUID
    var templateName: String?
    var date: Date
    @Relationship(deleteRule: .cascade) var exercises: [Exercise]
    var isCompleted: Bool
    var notes: String?
    
    init(
        templateName: String? = nil,
        date: Date = Date(),
        exercises: [Exercise] = [],
        isCompleted: Bool = false,
        notes: String? = nil
    ) {
        self.id = UUID()
        self.templateName = templateName
        self.date = date
        self.exercises = exercises
        self.isCompleted = isCompleted
        self.notes = notes
    }
    
    // MARK: - UI Helper Properties
    
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
    
    // MARK: - Workout State Helpers
    
    var isInFuture: Bool {
        Calendar.current.startOfDay(for: date) > Calendar.current.startOfDay(for: Date())
    }
    
    var isToday: Bool {
        Calendar.current.isDateInToday(date)
    }
    
    var isInPast: Bool {
        Calendar.current.startOfDay(for: date) < Calendar.current.startOfDay(for: Date())
    }
    
    var isScheduled: Bool {
        !isCompleted && isInFuture
    }
    
    var isInProgress: Bool {
        !isCompleted && (isToday || isInPast) && completedSets > 0
    }
    
    var hasStarted: Bool {
        completedSets > 0
    }
    
    // MARK: - Initialize from Template
    
    static func fromTemplate(_ template: WorkoutTemplate, date: Date = Date()) -> WorkoutSession {
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
            date: date,
            exercises: exercises
        )
    }
}
