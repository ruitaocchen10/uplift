//
//  ProgressView.swift
//  uplift
//
//  Created by Ruitao Chen on 12/4/25.
//

import SwiftUI

struct ProgressView: View {
    // DUMMY DATA - Using workouts from HomeView
    @State private var workouts: [WorkoutSession] = DummyData.sampleWorkouts
    @State private var selectedMonth: Date = Date()
    @State private var selectedExercise: ExerciseStats?
    
    private var workoutDates: Set<Date> {
        ProgressCalculations.getWorkoutDates(from: workouts)
    }
    
    private var exerciseStats: [ExerciseStats] {
        ProgressCalculations.calculateExerciseStats(from: workouts)
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.black.ignoresSafeArea()
                
                if exerciseStats.isEmpty {
                    // Empty State
                    emptyStateView
                } else {
                    ScrollView {
                        VStack(spacing: 24) {
                            // Monthly Calendar Heatmap
                            calendarSection
                            
                            // Exercise List
                            exerciseListSection
                        }
                        .padding(.vertical)
                    }
                }
            }
            .navigationTitle("Progress")
            .navigationBarTitleDisplayMode(.large)
            .sheet(item: $selectedExercise) { stats in
                ExerciseDetailView(exerciseStats: stats)
            }
        }
    }
    
    // MARK: - Empty State
    
    private var emptyStateView: some View {
        VStack(spacing: 24) {
            Image(systemName: "chart.line.uptrend.xyaxis")
                .font(.futuraTitle())
                .foregroundColor(.gray)
            
            VStack(spacing: 8) {
                Text("No Workouts Completed Yet")
                    .font(.futuraTitle2())
                    .foregroundColor(.white)
                
                Text("Complete your first workout to start tracking progress")
                    .font(.futuraBody())
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
            }
        }
    }
    
    // MARK: - Calendar Section
    
    private var calendarSection: some View {
        VStack(spacing: 12) {
            // Month Navigation
            HStack {
                Button(action: previousMonth) {
                    Image(systemName: "chevron.left")
                        .foregroundColor(.white)
                        .font(.futuraTitle3())
                }
                
                Spacer()
                
                Text(monthYearString)
                    .font(.futuraTitle3())
                    .foregroundColor(.white)
                
                Spacer()
                
                Button(action: nextMonth) {
                    Image(systemName: "chevron.right")
                        .foregroundColor(.white)
                        .font(.futuraTitle3())
                }
            }
            .padding(.horizontal)
            
            // Calendar Grid
            MonthlyCalendarHeatmap(
                selectedMonth: selectedMonth,
                workoutDates: workoutDates
            )
            .padding(.horizontal)
        }
    }
    
    // MARK: - Exercise List Section
    
    private var exerciseListSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Progress")
                    .font(.futuraTitle3())
                    .foregroundColor(.white)
                
                Spacer()
                
                // Future: Add sorting options here
            }
            .padding(.horizontal)
            
            ForEach(exerciseStats) { stats in
                Button(action: {
                    selectedExercise = stats
                }) {
                    ExerciseStatsRow(stats: stats)
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
    }
    
    // MARK: - Helper Methods
    
    private var monthYearString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter.string(from: selectedMonth)
    }
    
    private func previousMonth() {
        let calendar = Calendar.current
        selectedMonth = calendar.date(byAdding: .month, value: -1, to: selectedMonth) ?? selectedMonth
    }
    
    private func nextMonth() {
        let calendar = Calendar.current
        selectedMonth = calendar.date(byAdding: .month, value: 1, to: selectedMonth) ?? selectedMonth
    }
}

// MARK: - Monthly Calendar Heatmap

struct MonthlyCalendarHeatmap: View {
    let selectedMonth: Date
    let workoutDates: Set<Date>
    
    private let calendar = Calendar.current
    private let daysOfWeek = ["M", "T", "W", "T", "F", "S", "S"]
    
    private var monthDates: [[Date?]] {
        guard let monthInterval = calendar.dateInterval(of: .month, for: selectedMonth) else {
            return []
        }
        
        let firstDayOfMonth = monthInterval.start
        let lastDayOfMonth = calendar.date(byAdding: .day, value: -1, to: monthInterval.end) ?? monthInterval.end
        
        // Get weekday of first day (1 = Sunday, 2 = Monday, etc.)
        let firstWeekday = calendar.component(.weekday, from: firstDayOfMonth)
        let offsetDays = (firstWeekday == 1) ? 6 : firstWeekday - 2 // Convert to Monday start
        
        // Get number of days in month
        let daysInMonth = calendar.component(.day, from: lastDayOfMonth)
        
        // Build calendar grid
        var weeks: [[Date?]] = []
        var currentWeek: [Date?] = Array(repeating: nil, count: offsetDays)
        
        for day in 1...daysInMonth {
            if let date = calendar.date(byAdding: .day, value: day - 1, to: firstDayOfMonth) {
                currentWeek.append(date)
                
                if currentWeek.count == 7 {
                    weeks.append(currentWeek)
                    currentWeek = []
                }
            }
        }
        
        // Add remaining days to last week
        if !currentWeek.isEmpty {
            while currentWeek.count < 7 {
                currentWeek.append(nil)
            }
            weeks.append(currentWeek)
        }
        
        return weeks
    }
    
    var body: some View {
        VStack(spacing: 8) {
            // Day of week headers
            HStack(spacing: 0) {
                ForEach(daysOfWeek, id: \.self) { day in
                    Text(day)
                        .font(.futuraCaption())
                        .foregroundColor(.gray)
                        .frame(maxWidth: .infinity)
                }
            }
            
            // Calendar grid
            VStack(spacing: 8) {
                ForEach(Array(monthDates.enumerated()), id: \.offset) { _, week in
                    HStack(spacing: 8) {
                        ForEach(Array(week.enumerated()), id: \.offset) { _, date in
                            if let date = date {
                                CalendarDayCell(
                                    date: date,
                                    hasWorkout: workoutDates.contains(calendar.startOfDay(for: date)),
                                    isToday: calendar.isDateInToday(date)
                                )
                            } else {
                                // Empty cell
                                Color.clear
                                    .frame(width: 36, height: 36)
                            }
                        }
                    }
                }
            }
        }
    }
}

// MARK: - Calendar Day Cell

struct CalendarDayCell: View {
    let date: Date
    let hasWorkout: Bool
    let isToday: Bool
    
    private var dayNumber: Int {
        Calendar.current.component(.day, from: date)
    }
    
    var body: some View {
        ZStack {
            // Background circle
            Circle()
                .fill(hasWorkout ? Color.white : Color.clear)
                .frame(width: 36, height: 36)
            
            // Border for today
            if isToday && !hasWorkout {
                Circle()
                    .stroke(Color.gray, lineWidth: 1)
                    .frame(width: 36, height: 36)
            }
            
            // Day number
            Text("\(dayNumber)")
                .font(.futuraBody())
                .foregroundColor(hasWorkout ? .black : .white)
        }
        .frame(width: 40, height: 40)
    }
}

// MARK: - Exercise Stats Row

struct ExerciseStatsRow: View {
    let stats: ExerciseStats
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(stats.exerciseName)
                    .font(.futuraHeadline())
                    .foregroundColor(.white)
                
                HStack(spacing: 8) {
                    Text("\(stats.totalWorkouts) workouts")
                        .font(.futuraCaption())
                        .foregroundColor(.gray)
                    
                    Text("•")
                        .font(.futuraCaption())
                        .foregroundColor(.gray)
                    
                    Text("PR: \(Int(stats.personalBest.weight)) lbs")
                        .font(.futuraCaption())
                        .foregroundColor(.gray)
                }
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .foregroundColor(.gray)
                .font(.futuraSubheadline())
        }
        .padding()
        .background(Color.gray.opacity(0.2))
        .cornerRadius(12)
        .padding(.horizontal)
    }
}

#Preview {
    ProgressView()
}
