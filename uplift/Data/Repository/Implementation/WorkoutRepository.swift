//
//  WorkoutRepository.swift
//  uplift
//
//  Created by Ruitao Chen on 12/15/25.
//

import Foundation
import SwiftData

/// Main repository implementation
/// Coordinates between local and (eventually) cloud data sources
class WorkoutRepository: WorkoutRepositoryProtocol {
    
    // MARK: - Properties
    
    private let localDataSource: LocalDataSource
    
    // MARK: - Initialization
    
    init(modelContext: ModelContext) {
        self.localDataSource = LocalDataSource(modelContext: modelContext)
    }
    
    // MARK: - Workout Operations
    
    func fetchWorkouts() async -> [WorkoutSession] {
        // For now, just use local data
        // Later, this will merge local + cloud
        return localDataSource.fetchAllWorkouts()
    }
    
    func save(_ workout: WorkoutSession) async throws {
        // Save to local database
        try localDataSource.saveWorkout(workout)
        
        // TODO: Later, also save to cloud
        // Task {
        //     try? await cloudDataSource.save(workout)
        // }
    }
    
    func delete(_ workout: WorkoutSession) async throws {
        // Delete from local database
        try localDataSource.deleteWorkout(workout)
        
        // TODO: Later, also delete from cloud
        // Task {
        //     try? await cloudDataSource.delete(workout.id)
        // }
    }
    
    // MARK: - Template Operations
    
    func fetchTemplates() async -> [WorkoutTemplate] {
        // For now, just use local data
        return localDataSource.fetchAllTemplates()
    }
    
    func save(_ template: WorkoutTemplate) async throws {
        // Save to local database
        try localDataSource.saveTemplate(template)
        
        // TODO: Later, also save to cloud
    }
    
    func delete(_ template: WorkoutTemplate) async throws {
        // Delete from local database
        try localDataSource.deleteTemplate(template)
        
        // TODO: Later, also delete from cloud
    }
}
