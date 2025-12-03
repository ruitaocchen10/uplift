//
//  WorkoutHistory.swift
//  uplift
//
//  Created by Ruitao Chen on 12/3/25.
//

import Foundation

struct WorkoutHistory: Codable {
    var sessions: [WorkoutSession]
    
    init(sessions: [WorkoutSession] = []) {
        self.sessions = sessions
    }
    
    // Get all sessions for a specific date
    func sessions(for date: Date) -> [WorkoutSession] {
        sessions.filter { Calendar.current.isDate($0.date, inSameDayAs: date) }
    }
    
    // Check if there's a workout on a specific date
    func hasWorkout(on date: Date) -> Bool {
        !sessions(for: date).isEmpty
    }
    
    // Get completed sessions for a specific date
    func completedSessions(for date: Date) -> [WorkoutSession] {
        sessions(for: date).filter { $0.isCompleted }
    }
    
    // Get all dates with workouts (for heatmap)
    func datesWithWorkouts() -> Set<Date> {
        Set(sessions.map { Calendar.current.startOfDay(for: $0.date) })
    }
    
    // Get workout streak
    func currentStreak() -> Int {
        let calendar = Calendar.current
        let sortedDates = datesWithWorkouts()
            .sorted(by: >)
        
        guard !sortedDates.isEmpty else { return 0 }
        
        var streak = 0
        var currentDate = calendar.startOfDay(for: Date())
        
        for date in sortedDates {
            if calendar.isDate(date, inSameDayAs: currentDate) {
                streak += 1
                currentDate = calendar.date(byAdding: .day, value: -1, to: currentDate)!
            } else if date < currentDate {
                break
            }
        }
        
        return streak
    }
    
    // Get sessions in a date range
    func sessions(from startDate: Date, to endDate: Date) -> [WorkoutSession] {
        sessions.filter { $0.date >= startDate && $0.date <= endDate }
    }
    
    // Get sessions for current week
    func sessionsThisWeek() -> [WorkoutSession] {
        let calendar = Calendar.current
        let now = Date()
        guard let weekStart = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: now)),
              let weekEnd = calendar.date(byAdding: .day, value: 7, to: weekStart) else {
            return []
        }
        return sessions(from: weekStart, to: weekEnd)
    }
    
    // Get sessions for current month
    func sessionsThisMonth() -> [WorkoutSession] {
        let calendar = Calendar.current
        let now = Date()
        guard let monthStart = calendar.date(from: calendar.dateComponents([.year, .month], from: now)),
              let monthEnd = calendar.date(byAdding: .month, value: 1, to: monthStart) else {
            return []
        }
        return sessions(from: monthStart, to: monthEnd)
    }
    
    // Statistics
    var totalWorkouts: Int {
        sessions.filter { $0.isCompleted }.count
    }
    
    var totalVolume: Double {
        sessions.filter { $0.isCompleted }.reduce(0) { $0 + $1.totalVolume }
    }
    
    var averageWorkoutDuration: TimeInterval? {
        let completedWithDuration = sessions.filter { $0.isCompleted && $0.duration != nil }
        guard !completedWithDuration.isEmpty else { return nil }
        
        let totalDuration = completedWithDuration.compactMap { $0.duration }.reduce(0, +)
        return totalDuration / Double(completedWithDuration.count)
    }
}
