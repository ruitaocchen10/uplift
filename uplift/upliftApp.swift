//
//  upliftApp.swift
//  uplift
//
//  Created by Ruitao Chen on 12/2/25.
//

import SwiftUI
import SwiftData

@main
struct upliftApp: App {
    let modelContainer: ModelContainer
    let workoutManager: WorkoutManager
    
    init() {
        do {
            let schema = Schema([
                WorkoutSession.self,
                Exercise.self,
                WorkoutSet.self,
                WorkoutTemplate.self,
                TemplateExercise.self
            ])
            let config = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
            modelContainer = try ModelContainer(for: schema, configurations: [config])
            
            let context = modelContainer.mainContext
            
            // ✅ NEW: Create repository
            let repository = WorkoutRepository(modelContext: context)
            
            // ✅ NEW: Pass repository to WorkoutManager
            workoutManager = WorkoutManager(repository: repository)
            
        } catch {
            fatalError("Failed to create ModelContainer: \(error)")
        }
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(workoutManager)
                .task {
                    // Seed with dummy data on first launch
                    await workoutManager.seedDataIfNeeded()
                }
        }
        .modelContainer(modelContainer)
    }
}
