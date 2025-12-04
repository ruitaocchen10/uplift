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
    // Published properties - views observe these
    @Published var workouts: [WorkoutSession] = []
    @Published var templates: [WorkoutTemplate] = []
    
    private let modelContext: ModelContext
    
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
        loadAllData()
    }
    
    // MARK: - Load Data
    
    private func loadAllData() {
        loadWorkouts()
        loadTemplates()
    }
    
    private func loadWorkouts() {
        let descriptor = FetchDescriptor<WorkoutSession>(
            sortBy: [SortDescriptor(\.date, order: .reverse)]
        )
        workouts = (try? modelContext.fetch(descriptor)) ?? []
    }
    
    private func loadTemplates() {
        let descriptor = FetchDescriptor<WorkoutTemplate>(
            sortBy: [SortDescriptor(\.name)]
        )
        templates = (try? modelContext.fetch(descriptor)) ?? []
    }
    
    // MARK: - Workout Operations
    
    func addWorkout(_ workout: WorkoutSession) {
        modelContext.insert(workout)
        try? modelContext.save()
        workouts.append(workout)
    }
    
    func updateWorkout(_ workout: WorkoutSession) {
        try? modelContext.save()
        loadWorkouts() // Refresh
    }
    
    func deleteWorkout(_ workout: WorkoutSession) {
        modelContext.delete(workout)
        try? modelContext.save()
        workouts.removeAll { $0.id == workout.id }
    }
    
    // MARK: - Template Operations
    
    func addTemplate(_ template: WorkoutTemplate) {
        modelContext.insert(template)
        try? modelContext.save()
        templates.append(template)
    }
    
    func updateTemplate(_ template: WorkoutTemplate) {
        try? modelContext.save()
        loadTemplates() // Refresh
    }
    
    func deleteTemplate(_ template: WorkoutTemplate) {
        modelContext.delete(template)
        try? modelContext.save()
        templates.removeAll { $0.id == template.id }
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
    
    func seedDataIfNeeded() {
        // Only seed if database is empty
        guard workouts.isEmpty && templates.isEmpty else { return }
        
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
            addTemplate(template)
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
            addWorkout(workout)
        }
    }
}
