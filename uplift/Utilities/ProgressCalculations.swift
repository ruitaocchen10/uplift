//
//  ProgressCalculations.swift
//  uplift
//
//  Created by Ruitao Chen on 12/4/25.
//

import Foundation

// MARK: - Data Models for Progress

struct ExerciseStats: Identifiable {
    let id = UUID()
    let exerciseName: String
    let personalBest: PersonalBest
    let totalWorkouts: Int
    let lastPerformed: Date?
    let maxWeightHistory: [DataPoint]
    let volumeHistory: [DataPoint]
}

struct PersonalBest {
    let weight: Double
    let reps: Int
    let date: Date
}

struct DataPoint: Identifiable {
    let id = UUID()
    let date: Date
    let value: Double
}

// MARK: - Progress Calculations

struct ProgressCalculations {
    
    // MARK: - Get Workout Dates for Heatmap
    
    static func getWorkoutDates(from workouts: [WorkoutSession]) -> Set<Date> {
        let calendar = Calendar.current
        let completedWorkouts = workouts.filter { $0.isCompleted }
        
        return Set(completedWorkouts.map { workout in
            calendar.startOfDay(for: workout.date)
        })
    }
    
    // MARK: - Calculate Exercise Stats
    
    static func calculateExerciseStats(from workouts: [WorkoutSession]) -> [ExerciseStats] {
        let completedWorkouts = workouts.filter { $0.isCompleted }
        
        // Group exercises by name
        var exerciseData: [String: [(date: Date, sets: [WorkoutSet])]] = [:]
        
        for workout in completedWorkouts {
            for exercise in workout.exercises {
                if exerciseData[exercise.name] == nil {
                    exerciseData[exercise.name] = []
                }
                exerciseData[exercise.name]?.append((date: workout.date, sets: exercise.sets))
            }
        }
        
        // Calculate stats for each exercise
        var stats: [ExerciseStats] = []
        
        for (exerciseName, sessions) in exerciseData {
            // Personal Best (absolute max weight)
            let personalBest = calculatePersonalBest(for: sessions)
            
            // Total workouts
            let totalWorkouts = sessions.count
            
            // Last performed
            let lastPerformed = sessions.map { $0.date }.max()
            
            // Max weight history (one data point per session)
            let maxWeightHistory = sessions.map { session in
                let maxWeight = session.sets
                    .filter { $0.isCompleted && $0.weight > 0 }
                    .map { $0.weight }
                    .max() ?? 0
                return DataPoint(date: session.date, value: maxWeight)
            }.sorted { $0.date < $1.date }
            
            // Volume history (total volume per session)
            let volumeHistory = sessions.map { session in
                let totalVolume = session.sets
                    .filter { $0.isCompleted }
                    .reduce(0.0) { $0 + ($1.weight * Double($1.reps)) }
                return DataPoint(date: session.date, value: totalVolume)
            }.sorted { $0.date < $1.date }
            
            let stat = ExerciseStats(
                exerciseName: exerciseName,
                personalBest: personalBest,
                totalWorkouts: totalWorkouts,
                lastPerformed: lastPerformed,
                maxWeightHistory: maxWeightHistory,
                volumeHistory: volumeHistory
            )
            
            stats.append(stat)
        }
        
        // Sort alphabetically
        return stats.sorted { $0.exerciseName < $1.exerciseName }
    }
    
    // MARK: - Calculate Personal Best
    
    private static func calculatePersonalBest(for sessions: [(date: Date, sets: [WorkoutSet])]) -> PersonalBest {
        var maxWeight: Double = 0
        var maxWeightReps: Int = 0
        var maxWeightDate: Date = Date()
        
        for session in sessions {
            for set in session.sets where set.isCompleted {
                if set.weight > maxWeight {
                    maxWeight = set.weight
                    maxWeightReps = set.reps
                    maxWeightDate = session.date
                }
            }
        }
        
        return PersonalBest(weight: maxWeight, reps: maxWeightReps, date: maxWeightDate)
    }
    
    // MARK: - Filter Data by Time Range
    
    enum TimeRange {
        case sevenDays
        case thirtyDays
        case ninetyDays
        case all
        
        var days: Int? {
            switch self {
            case .sevenDays: return 7
            case .thirtyDays: return 30
            case .ninetyDays: return 90
            case .all: return nil
            }
        }
    }
    
    static func filterDataPoints(_ dataPoints: [DataPoint], for timeRange: TimeRange) -> [DataPoint] {
        guard let days = timeRange.days else {
            return dataPoints
        }
        
        let calendar = Calendar.current
        let cutoffDate = calendar.date(byAdding: .day, value: -days, to: Date()) ?? Date()
        
        return dataPoints.filter { $0.date >= cutoffDate }
    }
}
