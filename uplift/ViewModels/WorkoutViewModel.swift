//
//  WorkoutViewModel.swift
//  uplift
//
//  Created by Ruitao Chen on 12/3/25.
//

import Foundation
import Combine

class WorkoutViewModel: ObservableObject {
    @Published var currentSession: WorkoutSession?
    @Published var isWorkoutActive: Bool = false
    @Published var selectedTemplate: WorkoutTemplate?
    
    private let storageManager = StorageManager.shared
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        // Check if there's an active (incomplete) workout
        loadActiveWorkout()
    }
    
    // MARK: - Workout Session Management
    
    func startWorkout(from template: WorkoutTemplate) {
        // Create new session from template
        var session = WorkoutSession.fromTemplate(template)
        session.startTime = Date()
        
        currentSession = session
        isWorkoutActive = true
        selectedTemplate = template
        
        // Update template's last used date
        storageManager.updateTemplateLastUsed(template.id)
        
        // Save the session
        storageManager.addWorkoutSession(session)
    }
    
    func startEmptyWorkout() {
        // Create empty workout session
        var session = WorkoutSession()
        session.startTime = Date()
        
        currentSession = session
        isWorkoutActive = true
        selectedTemplate = nil
        
        storageManager.addWorkoutSession(session)
    }
    
    func resumeWorkout(_ session: WorkoutSession) {
        currentSession = session
        isWorkoutActive = true
        selectedTemplate = storageManager.getTemplate(byId: session.templateId ?? UUID())
    }
    
    func pauseWorkout() {
        guard let session = currentSession else { return }
        storageManager.updateWorkoutSession(session)
    }
    
    func finishWorkout() {
        guard var session = currentSession else { return }
        
        session.endTime = Date()
        session.isCompleted = true
        
        storageManager.updateWorkoutSession(session)
        
        // Reset state
        currentSession = nil
        isWorkoutActive = false
        selectedTemplate = nil
    }
    
    func cancelWorkout() {
        guard let session = currentSession else { return }
        
        // Delete the incomplete session
        storageManager.deleteWorkoutSession(session)
        
        // Reset state
        currentSession = nil
        isWorkoutActive = false
        selectedTemplate = nil
    }
    
    // MARK: - Exercise Management
    
    func addExercise(_ exercise: Exercise) {
        guard var session = currentSession else { return }
        
        session.exercises.append(exercise)
        currentSession = session
        
        storageManager.updateWorkoutSession(session)
    }
    
    func updateExercise(_ exercise: Exercise) {
        guard var session = currentSession,
              let index = session.exercises.firstIndex(where: { $0.id == exercise.id }) else {
            return
        }
        
        session.exercises[index] = exercise
        currentSession = session
        
        storageManager.updateWorkoutSession(session)
    }
    
    func deleteExercise(_ exercise: Exercise) {
        guard var session = currentSession else { return }
        
        session.exercises.removeAll { $0.id == exercise.id }
        currentSession = session
        
        storageManager.updateWorkoutSession(session)
    }
    
    func toggleExerciseExpansion(_ exerciseId: UUID) {
        guard var session = currentSession,
              let index = session.exercises.firstIndex(where: { $0.id == exerciseId }) else {
            return
        }
        
        session.exercises[index].isExpanded.toggle()
        currentSession = session
    }
    
    // MARK: - Set Management
    
    func addSet(to exerciseId: UUID) {
        guard var session = currentSession,
              let exerciseIndex = session.exercises.firstIndex(where: { $0.id == exerciseId }) else {
            return
        }
        
        let newSet = WorkoutSet()
        session.exercises[exerciseIndex].sets.append(newSet)
        currentSession = session
        
        storageManager.updateWorkoutSession(session)
    }
    
    func updateSet(_ set: WorkoutSet, in exerciseId: UUID) {
        guard var session = currentSession,
              let exerciseIndex = session.exercises.firstIndex(where: { $0.id == exerciseId }),
              let setIndex = session.exercises[exerciseIndex].sets.firstIndex(where: { $0.id == set.id }) else {
            return
        }
        
        session.exercises[exerciseIndex].sets[setIndex] = set
        currentSession = session
        
        storageManager.updateWorkoutSession(session)
    }
    
    func deleteSet(_ setId: UUID, from exerciseId: UUID) {
        guard var session = currentSession,
              let exerciseIndex = session.exercises.firstIndex(where: { $0.id == exerciseId }) else {
            return
        }
        
        session.exercises[exerciseIndex].sets.removeAll { $0.id == setId }
        currentSession = session
        
        storageManager.updateWorkoutSession(session)
    }
    
    func toggleSetCompletion(_ setId: UUID, in exerciseId: UUID) {
        guard var session = currentSession,
              let exerciseIndex = session.exercises.firstIndex(where: { $0.id == exerciseId }),
              let setIndex = session.exercises[exerciseIndex].sets.firstIndex(where: { $0.id == setId }) else {
            return
        }
        
        session.exercises[exerciseIndex].sets[setIndex].isCompleted.toggle()
        currentSession = session
        
        storageManager.updateWorkoutSession(session)
    }
    
    // MARK: - Helper Methods
    
    private func loadActiveWorkout() {
        // Check for incomplete workouts from today
        let todaysSessions = storageManager.getWorkoutsForDate(Date())
        if let activeSession = todaysSessions.first(where: { !$0.isCompleted }) {
            currentSession = activeSession
            isWorkoutActive = true
            selectedTemplate = storageManager.getTemplate(byId: activeSession.templateId ?? UUID())
        }
    }
    
    func getWorkoutDuration() -> String {
        guard let session = currentSession,
              let startTime = session.startTime else {
            return "0:00"
        }
        
        let duration = Date().timeIntervalSince(startTime)
        let minutes = Int(duration) / 60
        let seconds = Int(duration) % 60
        
        return String(format: "%d:%02d", minutes, seconds)
    }
}
