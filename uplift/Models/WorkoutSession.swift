//
//  WorkoutSession.swift
//  uplift
//
//  Created by Ruitao Chen on 12/3/25.
//

import Foundation

struct WorkoutSession: Identifiable, Codable {
    let id: UUID
    var templateId: UUID? // Reference to template if created from one
    var templateName: String? // Store name for historical reference
    var date: Date
    var startTime: Date?
    var endTime: Date?
    var exercises: [Exercise] // Reusing existing Exercise model
    var isCompleted: Bool
    var notes: String?
    
    init(
        id: UUID = UUID(),
        templateId: UUID? = nil,
        templateName: String? = nil,
        date: Date = Date(),
        startTime: Date? = nil,
        endTime: Date? = nil,
        exercises: [Exercise] = [],
        isCompleted: Bool = false,
        notes: String? = nil
    ) {
        self.id = id
        self.templateId = templateId
        self.templateName = templateName
        self.date = date
        self.startTime = startTime
        self.endTime = endTime
        self.exercises = exercises
        self.isCompleted = isCompleted
        self.notes = notes
    }
    
    // Helper computed properties
    var duration: TimeInterval? {
        guard let start = startTime, let end = endTime else { return nil }
        return end.timeIntervalSince(start)
    }
    
    var durationFormatted: String? {
        guard let duration = duration else { return nil }
        let hours = Int(duration) / 3600
        let minutes = Int(duration) / 60 % 60
        
        if hours > 0 {
            return "\(hours)h \(minutes)m"
        } else {
            return "\(minutes)m"
        }
    }
    
    var totalVolume: Double {
        exercises.reduce(0) { $0 + $1.totalVolume }
    }
    
    var totalSets: Int {
        exercises.reduce(0) { $0 + $1.totalSets }
    }
    
    var completedSets: Int {
        exercises.reduce(0) { total, exercise in
            total + exercise.sets.filter { $0.isCompleted }.count
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
                sets: sets,
                isExpanded: false
            )
        }
        
        return WorkoutSession(
            templateId: template.id,
            templateName: template.name,
            date: Date(),
            exercises: exercises,
            isCompleted: false
        )
    }
}
