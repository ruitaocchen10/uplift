//
//  ProgressView.swift
//  uplift
//
//  Created by Ruitao Chen on 12/4/25.
//

import SwiftUI

struct ProgressView: View {
    // DUMMY DATA - Using workouts from HomeView
    @EnvironmentObject var workoutManager: WorkoutManager
    @State private var selectedMonth: Date = Date()
    @State private var selectedExercise: ExerciseStats?
    
    private var workoutDates: Set<Date> {
        workoutManager.workoutDates()
    }

    private var exerciseStats: [ExerciseStats] {
        workoutManager.exerciseStats()
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.black.ignoresSafeArea()
                
                VStack(spacing: 0) {
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
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    UserInitialsButton(initials: "RC", action: nil)
                }
                
                ToolbarItem(placement: .principal) {
                    HeaderTitle(title: "Progress")
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    SearchButton {
                        // TODO: Implement search
                    }
                }
            }
            .standardToolbar()
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
                Text(monthYearString)
                    .font(.futuraTitle3())
                    .foregroundColor(.white)
                
                Spacer()
                
                // Navigation arrows on the right
                HStack(spacing: 16) {
                    Button(action: previousMonth) {
                        Image(systemName: "chevron.left")
                            .foregroundColor(.white)
                            .font(.futuraBody())
                    }
                    
                    Button(action: nextMonth) {
                        Image(systemName: "chevron.right")
                            .foregroundColor(.white)
                            .font(.futuraBody())
                    }
                }
            }
            .padding(.horizontal)
            
            // Calendar Grid with border
            MonthlyCalendarHeatmap(
                selectedMonth: selectedMonth,
                workoutDates: workoutDates
            )
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.gray.opacity(0.1))
            )
            .fadeEdgeBorder(
                color: .white.opacity(0.4),
                cornerRadius: 16,
                lineWidth: 1,
                fadeStyle: .radial
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
        
        // FIXED: Add remaining days to last week and fill with nil
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
                                // Empty cell with subtle outline
                                Circle()
                                    .stroke(Color.gray.opacity(0.3), lineWidth: 1)  // Also increased opacity
                                    .frame(width: 36, height: 36)
                                    .frame(width: 40, height: 40)  // Add outer frame for consistent spacing
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
            if hasWorkout {
                // Workout day - filled white circle
                Circle()
                    .fill(Color.white)
                    .frame(width: 36, height: 36)  // Changed from 36 to match
                
                Text("\(dayNumber)")
                    .font(.futuraBody())
                    .foregroundColor(.black)
            } else {
                // No workout - subtle outline
                Circle()
                    .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                    .frame(width: 36, height: 36)
                
                Text("\(dayNumber)")
                    .font(.futuraBody())
                    .foregroundColor(.white)
            }
            
            // Today indicator - additional ring
            if isToday && !hasWorkout {
                Circle()
                    .stroke(Color.white, lineWidth: 2)
                    .frame(width: 36, height: 36)
            }
        }
        .frame(width: 40, height: 40)  // Keep outer frame for spacing
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
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.gray.opacity(0.2))
        )
        .fadeEdgeBorder(
            color: .white.opacity(0.4),
            cornerRadius: 16,
            lineWidth: 1,
            fadeStyle: .radial
        )
        .padding(.horizontal)
    }
}

#Preview {
    ProgressView()
}
