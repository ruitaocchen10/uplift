//
//  ProgressViewModel.swift
//  uplift
//
//  Created by Ruitao Chen on 12/3/25.
//

import Foundation
import Combine

class ProgressViewModel: ObservableObject {
    @Published var selectedExercise: String?
    @Published var selectedTimeframe: Timeframe = .month
    @Published var workoutHistory: WorkoutHistory
    
    private let storageManager = StorageManager.shared
    private var cancellables = Set<AnyCancellable>()
    
    enum Timeframe: String, CaseIterable {
        case week = "Week"
        case month = "Month"
        case threeMonths = "3 Months"
        case year = "Year"
        case allTime = "All Time"
        
        var days: Int? {
            switch self {
            case .week: return 7
            case .month: return 30
            case .threeMonths: return 90
            case .year: return 365
            case .allTime: return nil
            }
        }
    }
    
    init() {
        self.workoutHistory = storageManager.workoutHistory
        
        // Observe storage manager changes
        storageManager.$workoutHistory
            .assign(to: \.workoutHistory, on: self)
            .store(in: &cancellables)
    }
    
    // MARK: - General Statistics
    
    func getTotalWorkouts() -> Int {
        getFilteredSessions().filter { $0.isCompleted }.count
    }
    
    func getTotalVolume() -> Double {
        getFilteredSessions()
            .filter { $0.isCompleted }
            .reduce(0) { $0 + $1.totalVolume }
    }
    
    func getAverageDuration() -> String {
        let sessions = getFilteredSessions().filter { $0.isCompleted && $0.duration != nil }
        guard !sessions.isEmpty else { return "N/A" }
        
        let totalDuration = sessions.compactMap { $0.duration }.reduce(0, +)
        let average = totalDuration / Double(sessions.count)
        
        let hours = Int(average) / 3600
        let minutes = Int(average) / 60 % 60
        
        if hours > 0 {
            return "\(hours)h \(minutes)m"
        } else {
            return "\(minutes)m"
        }
    }
    
    func getCurrentStreak() -> Int {
        storageManager.getCurrentStreak()
    }
    
    func getWorkoutsThisWeek() -> Int {
        storageManager.getWorkoutsThisWeek().filter { $0.isCompleted }.count
    }
    
    // MARK: - Exercise-Specific Progress
    
    func getAllExerciseNames() -> [String] {
        let allExercises = workoutHistory.sessions
            .flatMap { $0.exercises }
            .map { $0.name }
        
        return Array(Set(allExercises)).sorted()
    }
    
    func getExerciseHistory(for exerciseName: String) -> [ExercisePerformance] {
        let sessions = getFilteredSessions().filter { $0.isCompleted }
        
        var performances: [ExercisePerformance] = []
        
        for session in sessions {
            if let exercise = session.exercises.first(where: { $0.name == exerciseName }) {
                let performance = ExercisePerformance(
                    date: session.date,
                    exercise: exercise
                )
                performances.append(performance)
            }
        }
        
        return performances.sorted { $0.date < $1.date }
    }
    
    func getMaxWeight(for exerciseName: String) -> Double? {
        let performances = getExerciseHistory(for: exerciseName)
        return performances.compactMap { $0.maxWeight }.max()
    }
    
    func getMaxVolume(for exerciseName: String) -> Double? {
        let performances = getExerciseHistory(for: exerciseName)
        return performances.map { $0.totalVolume }.max()
    }
    
    func getPersonalRecords() -> [PersonalRecord] {
        let exerciseNames = getAllExerciseNames()
        
        return exerciseNames.compactMap { name in
            guard let maxWeight = getMaxWeight(for: name),
                  let performance = getExerciseHistory(for: name)
                    .first(where: { $0.maxWeight == maxWeight }) else {
                return nil
            }
            
            return PersonalRecord(
                exerciseName: name,
                weight: maxWeight,
                reps: performance.maxWeightReps ?? 0,
                date: performance.date
            )
        }.sorted { $0.date > $1.date }
    }
    
    // MARK: - Heatmap Data
    
    func getDatesWithWorkouts() -> Set<Date> {
        storageManager.getDatesWithWorkouts()
    }
    
    func hasWorkout(on date: Date) -> Bool {
        storageManager.hasWorkoutOnDate(date)
    }
    
    func getWorkoutIntensity(for date: Date) -> Double {
        let sessions = storageManager.getWorkoutsForDate(date).filter { $0.isCompleted }
        guard !sessions.isEmpty else { return 0 }
        
        let totalVolume = sessions.reduce(0) { $0 + $1.totalVolume }
        
        // Normalize intensity (you can adjust this scale based on your needs)
        // Assuming average workout volume of 10,000 lbs
        return min(totalVolume / 10000.0, 1.0)
    }
    
    // MARK: - Volume Tracking
    
    func getVolumeByWeek() -> [(week: Date, volume: Double)] {
        let calendar = Calendar.current
        let sessions = getFilteredSessions().filter { $0.isCompleted }
        
        var volumeByWeek: [Date: Double] = [:]
        
        for session in sessions {
            guard let weekStart = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: session.date)) else {
                continue
            }
            
            volumeByWeek[weekStart, default: 0] += session.totalVolume
        }
        
        return volumeByWeek.map { (week: $0.key, volume: $0.value) }
            .sorted { $0.week < $1.week }
    }
    
    func getVolumeByMonth() -> [(month: Date, volume: Double)] {
        let calendar = Calendar.current
        let sessions = getFilteredSessions().filter { $0.isCompleted }
        
        var volumeByMonth: [Date: Double] = [:]
        
        for session in sessions {
            guard let monthStart = calendar.date(from: calendar.dateComponents([.year, .month], from: session.date)) else {
                continue
            }
            
            volumeByMonth[monthStart, default: 0] += session.totalVolume
        }
        
        return volumeByMonth.map { (month: $0.key, volume: $0.value) }
            .sorted { $0.month < $1.month }
    }
    
    // MARK: - Helper Methods
    
    private func getFilteredSessions() -> [WorkoutSession] {
        guard let days = selectedTimeframe.days else {
            return workoutHistory.sessions
        }
        
        let calendar = Calendar.current
        guard let startDate = calendar.date(byAdding: .day, value: -days, to: Date()) else {
            return workoutHistory.sessions
        }
        
        return workoutHistory.sessions.filter { $0.date >= startDate }
    }
}

// MARK: - Supporting Models

struct ExercisePerformance {
    let date: Date
    let exercise: Exercise
    
    var maxWeight: Double? {
        exercise.sets.compactMap { $0.isCompleted ? $0.weight : nil }.max()
    }
    
    var maxWeightReps: Int? {
        guard let maxWeight = maxWeight else { return nil }
        return exercise.sets.first { $0.weight == maxWeight && $0.isCompleted }?.reps
    }
    
    var totalVolume: Double {
        exercise.totalVolume
    }
    
    var averageWeight: Double {
        let completedSets = exercise.sets.filter { $0.isCompleted }
        guard !completedSets.isEmpty else { return 0 }
        
        let totalWeight = completedSets.reduce(0) { $0 + $1.weight }
        return totalWeight / Double(completedSets.count)
    }
}

struct PersonalRecord: Identifiable {
    let id = UUID()
    let exerciseName: String
    let weight: Double
    let reps: Int
    let date: Date
    
    var displayString: String {
        "\(Int(weight)) lbs × \(reps) reps"
    }
}
