//
//  StorageManager.swift
//  uplift
//
//  Created by Ruitao Chen on 12/3/25.
//

import Foundation
import Combine

class StorageManager: ObservableObject {
    static let shared = StorageManager()
    private let userDefaultsManager = UserDefaultsManager.shared
    
    // Published properties for SwiftUI observation
    @Published var userProfile: UserProfile?
    @Published var workoutHistory: WorkoutHistory
    @Published var templates: [WorkoutTemplate]
    
    private init() {
        // Load existing data on initialization
        self.userProfile = userDefaultsManager.loadUserProfile()
        self.workoutHistory = userDefaultsManager.loadWorkoutHistory()
        self.templates = userDefaultsManager.loadTemplates()
        
        // Create default profile if none exists
        if userProfile == nil {
            let defaultProfile = UserProfile(name: "User")
            self.userProfile = defaultProfile
            saveUserProfile(defaultProfile)
        }
    }
    
    // MARK: - User Profile Operations
    
    func saveUserProfile(_ profile: UserProfile) {
        self.userProfile = profile
        userDefaultsManager.saveUserProfile(profile)
    }
    
    func updateUserName(_ name: String) {
        guard var profile = userProfile else { return }
        profile.name = name
        saveUserProfile(profile)
    }
    
    func updateUserPreferences(_ preferences: UserPreferences) {
        guard var profile = userProfile else { return }
        profile.preferences = preferences
        saveUserProfile(profile)
    }
    
    // MARK: - Workout Session Operations
    
    func addWorkoutSession(_ session: WorkoutSession) {
        workoutHistory.sessions.append(session)
        userDefaultsManager.saveWorkoutHistory(workoutHistory)
    }
    
    func updateWorkoutSession(_ session: WorkoutSession) {
        if let index = workoutHistory.sessions.firstIndex(where: { $0.id == session.id }) {
            workoutHistory.sessions[index] = session
            userDefaultsManager.saveWorkoutHistory(workoutHistory)
        }
    }
    
    func deleteWorkoutSession(_ session: WorkoutSession) {
        workoutHistory.sessions.removeAll { $0.id == session.id }
        userDefaultsManager.saveWorkoutHistory(workoutHistory)
    }
    
    func getSession(byId id: UUID) -> WorkoutSession? {
        workoutHistory.sessions.first { $0.id == id }
    }
    
    // MARK: - Template Operations
    
    func addTemplate(_ template: WorkoutTemplate) {
        templates.append(template)
        userDefaultsManager.saveTemplates(templates)
    }
    
    func updateTemplate(_ template: WorkoutTemplate) {
        if let index = templates.firstIndex(where: { $0.id == template.id }) {
            templates[index] = template
            userDefaultsManager.saveTemplates(templates)
        }
    }
    
    func deleteTemplate(_ template: WorkoutTemplate) {
        templates.removeAll { $0.id == template.id }
        userDefaultsManager.saveTemplates(templates)
    }
    
    func getTemplate(byId id: UUID) -> WorkoutTemplate? {
        templates.first { $0.id == id }
    }
    
    func updateTemplateLastUsed(_ templateId: UUID) {
        if let index = templates.firstIndex(where: { $0.id == templateId }) {
            templates[index].lastUsedDate = Date()
            userDefaultsManager.saveTemplates(templates)
        }
    }
    
    // MARK: - Workout History Queries
    
    func getWorkoutsForDate(_ date: Date) -> [WorkoutSession] {
        workoutHistory.sessions(for: date)
    }
    
    func hasWorkoutOnDate(_ date: Date) -> Bool {
        workoutHistory.hasWorkout(on: date)
    }
    
    func getDatesWithWorkouts() -> Set<Date> {
        workoutHistory.datesWithWorkouts()
    }
    
    func getCurrentStreak() -> Int {
        workoutHistory.currentStreak()
    }
    
    func getWorkoutsThisWeek() -> [WorkoutSession] {
        workoutHistory.sessionsThisWeek()
    }
    
    func getWorkoutsThisMonth() -> [WorkoutSession] {
        workoutHistory.sessionsThisMonth()
    }
    
    // MARK: - Statistics
    
    func getTotalWorkouts() -> Int {
        workoutHistory.totalWorkouts
    }
    
    func getTotalVolume() -> Double {
        workoutHistory.totalVolume
    }
    
    func getAverageWorkoutDuration() -> TimeInterval? {
        workoutHistory.averageWorkoutDuration
    }
    
    // MARK: - Data Management
    
    func clearAllData() {
        userDefaultsManager.clearAllData()
        self.userProfile = nil
        self.workoutHistory = WorkoutHistory()
        self.templates = []
    }
    
    // MARK: - Sample Data (for testing/preview)
    
    func loadSampleData() {
        // Create sample templates
        let pushTemplate = WorkoutTemplate(
            name: "Hypertrophy Push Workout",
            exercises: [
                TemplateExercise(name: "Bench Press", targetSets: 3, targetRepsMin: 12, targetRepsMax: 15, order: 0),
                TemplateExercise(name: "Overhead Press", targetSets: 3, targetRepsMin: 10, targetRepsMax: 12, order: 1),
                TemplateExercise(name: "Incline Dumbbell Press", targetSets: 3, targetRepsMin: 12, targetRepsMax: 15, order: 2),
                TemplateExercise(name: "Tricep Pushdown", targetSets: 3, targetRepsMin: 12, targetRepsMax: 15, order: 3)
            ]
        )
        
        let pullTemplate = WorkoutTemplate(
            name: "Pull Day",
            exercises: [
                TemplateExercise(name: "Pull-ups", targetSets: 4, targetRepsMin: 8, targetRepsMax: 10, order: 0),
                TemplateExercise(name: "Barbell Row", targetSets: 3, targetRepsMin: 10, targetRepsMax: 12, order: 1),
                TemplateExercise(name: "Face Pulls", targetSets: 3, targetRepsMin: 15, targetRepsMax: 20, order: 2)
            ]
        )
        
        templates = [pushTemplate, pullTemplate]
        userDefaultsManager.saveTemplates(templates)
        
        // Create sample workout session
        var sampleSession = WorkoutSession.fromTemplate(pushTemplate)
        sampleSession.date = Date()
        sampleSession.isCompleted = false
        
        workoutHistory.sessions.append(sampleSession)
        userDefaultsManager.saveWorkoutHistory(workoutHistory)
    }
}
