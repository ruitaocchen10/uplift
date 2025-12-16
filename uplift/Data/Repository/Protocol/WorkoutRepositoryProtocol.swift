//
//  WorkoutRepositoryProtocol.swift
//  uplift
//
//  Created by Ruitao Chen on 12/15/25.
//

import Foundation

/// Protocol defining all data operations for workouts and templates
/// This allows us to swap implementations (local vs cloud) without changing the ViewModel
protocol WorkoutRepositoryProtocol {
    
    // MARK: - Workout Operations
    
    /// Fetch all workouts
    func fetchWorkouts() async -> [WorkoutSession]
    
    /// Save a workout (create or update)
    func save(_ workout: WorkoutSession) async throws
    
    /// Delete a workout
    func delete(_ workout: WorkoutSession) async throws
    
    // MARK: - Template Operations
    
    /// Fetch all templates
    func fetchTemplates() async -> [WorkoutTemplate]
    
    /// Save a template (create or update)
    func save(_ template: WorkoutTemplate) async throws
    
    /// Delete a template
    func delete(_ template: WorkoutTemplate) async throws
}

