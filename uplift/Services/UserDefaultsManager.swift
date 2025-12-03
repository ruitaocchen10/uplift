//
//  UserDefaultsManager.swift
//  uplift
//
//  Created by Ruitao Chen on 12/3/25.
//

import Foundation

class UserDefaultsManager {
    static let shared = UserDefaultsManager()
    private let defaults = UserDefaults.standard
    
    // Keys for UserDefaults
    private enum Keys {
        static let userProfile = "userProfile"
        static let workoutHistory = "workoutHistory"
        static let templates = "workoutTemplates"
        static let hasCompletedOnboarding = "hasCompletedOnboarding"
    }
    
    private init() {}
    
    // MARK: - User Profile
    
    func saveUserProfile(_ profile: UserProfile) {
        if let encoded = try? JSONEncoder().encode(profile) {
            defaults.set(encoded, forKey: Keys.userProfile)
        }
    }
    
    func loadUserProfile() -> UserProfile? {
        guard let data = defaults.data(forKey: Keys.userProfile),
              let profile = try? JSONDecoder().decode(UserProfile.self, from: data) else {
            return nil
        }
        return profile
    }
    
    func deleteUserProfile() {
        defaults.removeObject(forKey: Keys.userProfile)
    }
    
    // MARK: - Workout History
    
    func saveWorkoutHistory(_ history: WorkoutHistory) {
        if let encoded = try? JSONEncoder().encode(history) {
            defaults.set(encoded, forKey: Keys.workoutHistory)
        }
    }
    
    func loadWorkoutHistory() -> WorkoutHistory {
        guard let data = defaults.data(forKey: Keys.workoutHistory),
              let history = try? JSONDecoder().decode(WorkoutHistory.self, from: data) else {
            return WorkoutHistory()
        }
        return history
    }
    
    func deleteWorkoutHistory() {
        defaults.removeObject(forKey: Keys.workoutHistory)
    }
    
    // MARK: - Templates
    
    func saveTemplates(_ templates: [WorkoutTemplate]) {
        if let encoded = try? JSONEncoder().encode(templates) {
            defaults.set(encoded, forKey: Keys.templates)
        }
    }
    
    func loadTemplates() -> [WorkoutTemplate] {
        guard let data = defaults.data(forKey: Keys.templates),
              let templates = try? JSONDecoder().decode([WorkoutTemplate].self, from: data) else {
            return []
        }
        return templates
    }
    
    func deleteTemplates() {
        defaults.removeObject(forKey: Keys.templates)
    }
    
    // MARK: - Onboarding
    
    var hasCompletedOnboarding: Bool {
        get { defaults.bool(forKey: Keys.hasCompletedOnboarding) }
        set { defaults.set(newValue, forKey: Keys.hasCompletedOnboarding) }
    }
    
    // MARK: - Clear All Data
    
    func clearAllData() {
        deleteUserProfile()
        deleteWorkoutHistory()
        deleteTemplates()
        defaults.removeObject(forKey: Keys.hasCompletedOnboarding)
    }
}
