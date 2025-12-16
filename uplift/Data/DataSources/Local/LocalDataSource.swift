//
//  LocalDataSource.swift
//  uplift
//
//  Created by Ruitao Chen on 12/15/25.
//

import Foundation
import SwiftData

/// Handles all local database operations using SwiftData
/// This class is the ONLY place that knows about ModelContext
class LocalDataSource {
    
    // MARK: - Properties
    
    private let modelContext: ModelContext
    
    // MARK: - Initialization
    
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }
    
    // MARK: - Workout Operations
    
    /// Fetch all workouts from local database
    func fetchAllWorkouts() -> [WorkoutSession] {
        let descriptor = FetchDescriptor<WorkoutSession>(
            sortBy: [SortDescriptor(\.date, order: .reverse)]
        )
        return (try? modelContext.fetch(descriptor)) ?? []
    }
    
    /// Save a workout to local database
    func saveWorkout(_ workout: WorkoutSession) throws {
        modelContext.insert(workout)
        try modelContext.save()
    }
    
    /// Delete a workout from local database
    func deleteWorkout(_ workout: WorkoutSession) throws {
        modelContext.delete(workout)
        try modelContext.save()
    }
    
    // MARK: - Template Operations
    
    /// Fetch all templates from local database
    func fetchAllTemplates() -> [WorkoutTemplate] {
        let descriptor = FetchDescriptor<WorkoutTemplate>(
            sortBy: [SortDescriptor(\.name)]
        )
        return (try? modelContext.fetch(descriptor)) ?? []
    }
    
    /// Save a template to local database
    func saveTemplate(_ template: WorkoutTemplate) throws {
        modelContext.insert(template)
        try modelContext.save()
    }
    
    /// Delete a template from local database
    func deleteTemplate(_ template: WorkoutTemplate) throws {
        modelContext.delete(template)
        try modelContext.save()
    }
}

