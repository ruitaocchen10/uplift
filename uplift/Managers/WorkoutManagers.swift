//
//  WorkoutManager.swift
//  uplift
//
//  Created by Ruitao Chen on 12/4/25.
//

import Combine
import Foundation
import SwiftData

@MainActor
class WorkoutManager: ObservableObject {
    @Published var workouts: [WorkoutSession] = []
    @Published var templates: [WorkoutTemplate] = []
    
    private let repository: WorkoutRepositoryProtocol  // ✅ NEW
    
    init(repository: WorkoutRepositoryProtocol) {      // ✅ NEW
        self.repository = repository
        Task {
            await loadAllData()  // ✅ Now async
        }
    }
    
    // MARK: - Load Data
    
    private func loadAllData() async {
        await loadWorkouts()
        await loadTemplates()
    }
    
    private func loadWorkouts() async {
        workouts = await repository.fetchWorkouts()
    }
    
    private func loadTemplates() async {
        templates = await repository.fetchTemplates()
    }
    
    // MARK: - Workout Operations
    
    func addWorkout(_ workout: WorkoutSession) async {
        try? await repository.save(workout)
        await loadWorkouts()
    }
    
    func updateWorkout(_ workout: WorkoutSession) async {
        try? await repository.save(workout)
        await loadWorkouts()
    }
    
    func deleteWorkout(_ workout: WorkoutSession) async {
        try? await repository.delete(workout)
        await loadWorkouts()
    }
    
    // MARK: - Template Operations
    
    func addTemplate(_ template: WorkoutTemplate) async {
        try? await repository.save(template)
        await loadTemplates()
    }
    
    func updateTemplate(_ template: WorkoutTemplate) async {
        try? await repository.save(template)
        await loadTemplates()
    }
    
    func deleteTemplate(_ template: WorkoutTemplate) async {
        try? await repository.delete(template)
        await loadTemplates()
    }
    
    // MARK: - Helper Methods
    
    func workouts(for date: Date) -> [WorkoutSession] {
        workouts.filter { Calendar.current.isDate($0.date, inSameDayAs: date) }
    }
    
    func workoutDates() -> Set<Date> {
        let calendar = Calendar.current
        let completedWorkouts = workouts.filter { $0.isCompleted }
        return Set(completedWorkouts.map { calendar.startOfDay(for: $0.date) })
    }
    
    func exerciseStats() -> [ExerciseStats] {
        ProgressCalculations.calculateExerciseStats(from: workouts)
    }
    
    // MARK: - Seeding (Optional)

    func seedDataIfNeeded() async {
        // Check if we've already seeded using persistent flag
        let hasSeeded = UserDefaults.standard.bool(forKey: "hasSeededData")
        
        guard !hasSeeded else {
            print("✅ Data already seeded, skipping")
            return
        }
        
        print("🌱 First launch - seeding dummy data")
        
        // Add templates
        for templateData in DummyData.sampleTemplates {
            let template = WorkoutTemplate(
                name: templateData.name,
                exercises: templateData.exercises.map { exerciseData in
                    TemplateExercise(
                        name: exerciseData.name,
                        targetSets: exerciseData.targetSets,
                        targetRepsMin: exerciseData.targetRepsMin,
                        targetRepsMax: exerciseData.targetRepsMax,
                        notes: exerciseData.notes
                    )
                }
            )
            try? await repository.save(template)
        }
        
        // Add workouts
        for workoutData in DummyData.sampleWorkouts {
            let workout = WorkoutSession(
                templateName: workoutData.templateName,
                date: workoutData.date,
                exercises: workoutData.exercises.map { exerciseData in
                    Exercise(
                        name: exerciseData.name,
                        sets: exerciseData.sets.map { setData in
                            WorkoutSet(
                                weight: setData.weight,
                                reps: setData.reps,
                                isCompleted: setData.isCompleted
                            )
                        },
                        isExpanded: exerciseData.isExpanded
                    )
                },
                isCompleted: workoutData.isCompleted,
                notes: workoutData.notes
            )
            try? await repository.save(workout)
        }
        
        // Mark as seeded so this never runs again
        UserDefaults.standard.set(true, forKey: "hasSeededData")
        print("✅ Dummy data seeded successfully")
    }
}
