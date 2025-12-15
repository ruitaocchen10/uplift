//
//  ExerciseDetailView.swift
//  uplift
//
//  Created by Ruitao Chen on 12/4/25.
//

import SwiftUI
import Charts

struct ExerciseDetailView: View {
    let exerciseStats: ExerciseStats
    @Environment(\.dismiss) var dismiss
    
    @State private var selectedTimeRange: ProgressCalculations.TimeRange = .all
    
    private var filteredMaxWeightData: [DataPoint] {
        ProgressCalculations.filterDataPoints(exerciseStats.maxWeightHistory, for: selectedTimeRange)
    }
    
    private var filteredVolumeData: [DataPoint] {
        ProgressCalculations.filterDataPoints(exerciseStats.volumeHistory, for: selectedTimeRange)
    }
    
    // MARK: - Normalized Data for 7D Alignment
    
    /// Normalize data timestamps to midnight for 7D view to center points under day labels
    private var normalizedMaxWeightData: [DataPoint] {
        if selectedTimeRange == .sevenDays {
            let calendar = Calendar.current
            return filteredMaxWeightData.map { dataPoint in
                DataPoint(
                    date: calendar.startOfDay(for: dataPoint.date),
                    value: dataPoint.value
                )
            }
        } else {
            return filteredMaxWeightData
        }
    }
    
    /// Normalize data timestamps to midnight for 7D view to center points under day labels
    private var normalizedVolumeData: [DataPoint] {
        if selectedTimeRange == .sevenDays {
            let calendar = Calendar.current
            return filteredVolumeData.map { dataPoint in
                DataPoint(
                    date: calendar.startOfDay(for: dataPoint.date),
                    value: dataPoint.value
                )
            }
        } else {
            return filteredVolumeData
        }
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.black.ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Time Range Picker
                        timeRangePicker
                        
                        // Max Weight Chart
                        maxWeightChartSection
                        
                        // Total Volume Chart
                        totalVolumeChartSection
                    }
                    .padding(.vertical)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    BackButton {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .principal) {
                    HeaderTitle(
                        title: exerciseStats.exerciseName
                    )
                }
            }
            .standardToolbar()
        }
    }
    
    // MARK: - Time Range Picker
    
    private var timeRangePicker: some View {
        HStack(spacing: 12) {
            TimeRangeButton(
                title: "7D",
                isSelected: selectedTimeRange == .sevenDays,
                action: { selectedTimeRange = .sevenDays }
            )
            
            TimeRangeButton(
                title: "30D",
                isSelected: selectedTimeRange == .thirtyDays,
                action: { selectedTimeRange = .thirtyDays }
            )
            
            TimeRangeButton(
                title: "90D",
                isSelected: selectedTimeRange == .ninetyDays,
                action: { selectedTimeRange = .ninetyDays }
            )
            
            TimeRangeButton(
                title: "ALL",
                isSelected: selectedTimeRange == .all,
                action: { selectedTimeRange = .all }
            )
        }
        .padding(.horizontal)
    }
    
    // MARK: - Max Weight Chart Section
    
    private var maxWeightChartSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Max Weight")
                .font(.futuraHeadline())
                .foregroundColor(.white)
                .padding(.horizontal)
            
            if !hasDataForTimeRange(selectedTimeRange) {
                emptyChartView
            } else {
                Chart(normalizedMaxWeightData) { dataPoint in
                    LineMark(
                        x: .value("Date", dataPoint.date),
                        y: .value("Weight", dataPoint.value)
                    )
                    .foregroundStyle(Color.green)
                    .lineStyle(StrokeStyle(lineWidth: 2))
                    
                    PointMark(
                        x: .value("Date", dataPoint.date),
                        y: .value("Weight", dataPoint.value)
                    )
                    .foregroundStyle(Color.green)
                }
                .chartXScale(domain: getXAxisDomain(timeRange: selectedTimeRange))
                .chartXAxis {
                    AxisMarks(
                        position: .bottom,
                        values: generateXAxisValues(dataPoints: filteredMaxWeightData, timeRange: selectedTimeRange)
                    ) { value in
                        if let date = value.as(Date.self) {
                            AxisValueLabel {
                                Text(formatXAxisLabel(date: date, timeRange: selectedTimeRange))
                                    .font(.futuraCaption())
                                    .foregroundStyle(Color.gray)
                            }
                            // Grid line only at label positions
                            AxisGridLine()
                                .foregroundStyle(Color.gray.opacity(0.2))
                        }
                    }
                }
                .chartYAxis {
                    AxisMarks(values: .automatic) { _ in
                        AxisValueLabel()
                            .foregroundStyle(Color.gray)
                            .font(.futuraCaption())
                        AxisGridLine()
                            .foregroundStyle(Color.gray.opacity(0.1))
                    }
                }
                .frame(height: 200)
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.gray.opacity(0.1))
                )
                .fadeEdgeBorder(
                    color: .white.opacity(0.3),
                    cornerRadius: 12,
                    lineWidth: 1,
                    fadeStyle: .radial
                )
                .padding(.horizontal)
            }
            
            // Personal Best
            personalBestCard
        }
    }
    
    // MARK: - Total Volume Chart Section
    
    private var totalVolumeChartSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Total Volume")
                .font(.futuraHeadline())
                .foregroundColor(.white)
                .padding(.horizontal)
            
            if !hasDataForTimeRange(selectedTimeRange) {
                emptyChartView
            } else {
                Chart(normalizedVolumeData) { dataPoint in
                    BarMark(
                        x: .value("Date", dataPoint.date),
                        y: .value("Volume", dataPoint.value)
                    )
                    .foregroundStyle(Color.green)
                }
                .chartXScale(domain: getXAxisDomain(timeRange: selectedTimeRange))
                .chartXAxis {
                    AxisMarks(
                        position: .bottom,
                        values: generateXAxisValues(dataPoints: filteredVolumeData, timeRange: selectedTimeRange)
                    ) { value in
                        if let date = value.as(Date.self) {
                            AxisValueLabel {
                                Text(formatXAxisLabel(date: date, timeRange: selectedTimeRange))
                                    .font(.futuraCaption())
                                    .foregroundStyle(Color.gray)
                            }
                            // Grid line only at label positions
                            AxisGridLine()
                                .foregroundStyle(Color.gray.opacity(0.2))
                        }
                    }
                }
                .chartYAxis {
                    AxisMarks(values: .automatic) { _ in
                        AxisValueLabel()
                            .foregroundStyle(Color.gray)
                            .font(.futuraCaption())
                        AxisGridLine()
                            .foregroundStyle(Color.gray.opacity(0.1))
                    }
                }
                .frame(height: 200)
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.gray.opacity(0.1))
                )
                .fadeEdgeBorder(
                    color: .white.opacity(0.3),
                    cornerRadius: 12,
                    lineWidth: 1,
                    fadeStyle: .radial
                )
                .padding(.horizontal)
            }
            
            // Personal Best (same card for consistency)
            personalBestCard
        }
    }
    
    // MARK: - Personal Best Card
    
    private var personalBestCard: some View {
        HStack {
            Image(systemName: "trophy.fill")
                .foregroundColor(.yellow)
                .font(.futuraTitle3())
            
            VStack(alignment: .leading, spacing: 4) {
                Text("Personal Record")
                    .font(.futuraSubheadline())
                    .foregroundColor(.gray)
                
                Text("\(Int(exerciseStats.personalBest.weight)) lbs × \(exerciseStats.personalBest.reps) reps")
                    .font(.futuraHeadline())
                    .foregroundColor(.white)
                
                Text(formattedDate(exerciseStats.personalBest.date))
                    .font(.futuraCaption())
                    .foregroundColor(.gray)
            }
            
            Spacer()
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.gray.opacity(0.2))
        )
        .fadeEdgeBorder(
            color: .yellow.opacity(0.5),
            cornerRadius: 12,
            lineWidth: 1,
            fadeStyle: .radial
        )
        .padding(.horizontal)
    }
    
    // MARK: - Enhanced Empty Chart View
    
    private var emptyChartView: some View {
        VStack(spacing: 12) {
            Image(systemName: "chart.xyaxis.line")
                .font(.system(size: 40))
                .foregroundColor(.gray)
            
            // Contextual message based on validation failure
            let validation = validateDataForTimeRange(selectedTimeRange)
            
            if !validation.isValid {
                // Show what's missing
                Text(validation.primaryMessage)
                    .font(.futuraBody())
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                
                if let detail = validation.detailMessage {
                    Text(detail)
                        .font(.futuraSubheadline())
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                }
                
                Text(validation.actionMessage)
                    .font(.futuraSubheadline())
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
            }
        }
        .frame(height: 200)
        .frame(maxWidth: .infinity)
        .padding(.horizontal, 40)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.gray.opacity(0.1))
        )
        .fadeEdgeBorder(
            color: .white.opacity(0.3),
            cornerRadius: 12,
            lineWidth: 1,
            fadeStyle: .radial
        )
        .padding(.horizontal)
    }
    
    // MARK: - Data Availability Helpers
    
    /// Validation result structure
    private struct DataValidation {
        let isValid: Bool
        let primaryMessage: String
        let detailMessage: String?
        let actionMessage: String
    }
    
    /// Enhanced validation with minimum points and time span requirements
    private func validateDataForTimeRange(_ timeRange: ProgressCalculations.TimeRange) -> DataValidation {
        let filteredData = ProgressCalculations.filterDataPoints(exerciseStats.maxWeightHistory, for: timeRange)
        
        // Define requirements for each time range
        let minPoints: Int
        let minTimeSpanDays: Int?
        
        switch timeRange {
        case .sevenDays:
            minPoints = 2
            minTimeSpanDays = 2
        case .thirtyDays:
            minPoints = 2
            minTimeSpanDays = 7
        case .ninetyDays:
            minPoints = 3
            minTimeSpanDays = 30
        case .all:
            minPoints = 5
            minTimeSpanDays = 90
        }
        
        let actualPoints = filteredData.count
        
        // Check minimum data points
        guard actualPoints >= minPoints else {
            let primaryMessage: String
            let detailMessage: String?
            let actionMessage: String
            
            if actualPoints == 0 {
                primaryMessage = "No workouts in the last \(timeRangeLabel)"
                if lastWorkoutDate != nil {
                    detailMessage = "Last workout: \(timeSinceLastWorkout())"
                } else {
                    detailMessage = nil
                }
                actionMessage = "Complete a workout to start tracking!"
            } else {
                primaryMessage = "Not enough data for \(timeRangeLabel) view"
                detailMessage = "You have \(actualPoints) workout\(actualPoints == 1 ? "" : "s") (need \(minPoints)+)"
                actionMessage = "Keep training to unlock this chart!"
            }
            
            return DataValidation(
                isValid: false,
                primaryMessage: primaryMessage,
                detailMessage: detailMessage,
                actionMessage: actionMessage
            )
        }
        
        // Check time span requirement (if applicable)
        if let requiredSpan = minTimeSpanDays {
            let dates = filteredData.map { $0.date }.sorted()
            guard let earliest = dates.first,
                  let latest = dates.last else {
                return DataValidation(
                    isValid: false,
                    primaryMessage: "Unable to calculate time span",
                    detailMessage: nil,
                    actionMessage: "Try again later"
                )
            }
            
            let calendar = Calendar.current
            let daysBetween = calendar.dateComponents([.day], from: earliest, to: latest).day ?? 0
            
            guard daysBetween >= requiredSpan else {
                let primaryMessage = "Not enough data for \(timeRangeLabel) view"
                let detailMessage = "You have \(actualPoints) workout\(actualPoints == 1 ? "" : "s") across \(daysBetween) day\(daysBetween == 1 ? "" : "s")"
                let actionMessage = "Need \(minPoints)+ workouts across \(requiredSpan)+ days to see progress"
                
                return DataValidation(
                    isValid: false,
                    primaryMessage: primaryMessage,
                    detailMessage: detailMessage,
                    actionMessage: actionMessage
                )
            }
        }
        
        // Validation passed
        return DataValidation(
            isValid: true,
            primaryMessage: "",
            detailMessage: nil,
            actionMessage: ""
        )
    }
    
    /// Check if there's sufficient data for the time range (uses enhanced validation)
    private func hasDataForTimeRange(_ timeRange: ProgressCalculations.TimeRange) -> Bool {
        return validateDataForTimeRange(timeRange).isValid
    }
    
    /// Get the most recent workout date for this exercise
    private var lastWorkoutDate: Date? {
        exerciseStats.maxWeightHistory.map { $0.date }.max()
    }
    
    /// Human-readable time since last workout
    private func timeSinceLastWorkout() -> String {
        guard let lastDate = lastWorkoutDate else {
            return "Never"
        }
        
        let calendar = Calendar.current
        let now = Date()
        let components = calendar.dateComponents([.day, .weekOfYear, .month], from: lastDate, to: now)
        
        if let months = components.month, months > 0 {
            return months == 1 ? "1 month ago" : "\(months) months ago"
        } else if let weeks = components.weekOfYear, weeks > 0 {
            return weeks == 1 ? "1 week ago" : "\(weeks) weeks ago"
        } else if let days = components.day, days > 0 {
            return days == 1 ? "1 day ago" : "\(days) days ago"
        } else {
            return "Today"
        }
    }
    
    /// Get human-readable label for current time range
    private var timeRangeLabel: String {
        switch selectedTimeRange {
        case .sevenDays:
            return "7 days"
        case .thirtyDays:
            return "30 days"
        case .ninetyDays:
            return "90 days"
        case .all:
            return "all time"
        }
    }
    
    // MARK: - X-Axis Helpers
    
    /// Calculate stride for perfectly even spacing with exact label count
    private func calculateXAxisStride(timeRange: ProgressCalculations.TimeRange, dataPoints: [DataPoint]) -> Int {
        switch timeRange {
        case .sevenDays:
            // 7 days, 7 labels (one per day)
            return 1
        
        case .thirtyDays:
            // 30 days, 6 labels = 5 intervals
            // 30 / 5 = 6 days stride
            return 6
        
        case .ninetyDays:
            // 90 days, 6 labels = 5 intervals
            // 90 / 5 = 18 days stride
            return 18
        
        case .all:
            // Always 6 labels = 5 intervals for ALL view
            guard !dataPoints.isEmpty else { return 1 }
            
            let calendar = Calendar.current
            let daysBetween = calendar.dateComponents([.day],
                from: dataPoints.first!.date,
                to: dataPoints.last!.date
            ).day ?? 1
            
            // Target 6 labels = 5 intervals
            let stride = max(1, daysBetween / 5)
            return stride
        }
    }
    
    /// Format date labels based on time range
    private func formatXAxisLabel(date: Date, timeRange: ProgressCalculations.TimeRange) -> String {
        let formatter = DateFormatter()
        
        switch timeRange {
        case .sevenDays:
            // "M", "T", "W", "T", "F", "S", "S"
            formatter.dateFormat = "EEEEE"  // Single letter day
            
        case .thirtyDays:
            // "12/01", "12/06", "12/11"
            formatter.dateFormat = "MM/dd"
            
        case .ninetyDays:
            // "10/15", "11/01", "11/15", "12/01"
            formatter.dateFormat = "MM/dd"
            
        case .all:
            // "06/23", "09/23", "12/23"
            formatter.dateFormat = "MM/yy"
        }
        
        return formatter.string(from: date)
    }
    
    /// Generate evenly-spaced X-axis date values for perfect grid alignment
    private func generateXAxisValues(dataPoints: [DataPoint], timeRange: ProgressCalculations.TimeRange) -> [Date] {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        
        // Calculate start date and stride for perfect spacing
        let startDate: Date
        let stride: Int
        
        switch timeRange {
        case .sevenDays:
            // Show all 7 days
            startDate = calendar.date(byAdding: .day, value: -6, to: today) ?? today
            stride = 1
        
        case .thirtyDays:
            // 30 days with 6 labels = 6 day stride
            startDate = calendar.date(byAdding: .day, value: -30, to: today) ?? today
            stride = 6
        
        case .ninetyDays:
            // 90 days with 6 labels = 18 day stride
            startDate = calendar.date(byAdding: .day, value: -90, to: today) ?? today
            stride = 18
        
        case .all:
            // Use actual data range with calculated stride for 6 labels
            if let firstDate = dataPoints.first?.date {
                startDate = calendar.startOfDay(for: firstDate)
                stride = calculateXAxisStride(timeRange: timeRange, dataPoints: dataPoints)
            } else {
                startDate = calendar.date(byAdding: .day, value: -90, to: today) ?? today
                stride = 18
            }
        }
        
        let endDate = today
        
        // Generate evenly-spaced dates
        var dates: [Date] = []
        var currentDate = startDate
        
        while currentDate <= endDate {
            dates.append(currentDate)
            
            if let nextDate = calendar.date(byAdding: .day, value: stride, to: currentDate) {
                currentDate = nextDate
            } else {
                break
            }
        }
        
        return dates
    }
    
    /// Get the full date range for the X-axis domain
    private func getXAxisDomain(timeRange: ProgressCalculations.TimeRange) -> ClosedRange<Date> {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        
        let startDate: Date
        switch timeRange {
        case .sevenDays:
            // 7 days: today - 6 days
            startDate = calendar.date(byAdding: .day, value: -6, to: today) ?? today
        
        case .thirtyDays:
            // 30 days: today - 30 days
            startDate = calendar.date(byAdding: .day, value: -30, to: today) ?? today
        
        case .ninetyDays:
            // 90 days: today - 90 days
            startDate = calendar.date(byAdding: .day, value: -90, to: today) ?? today
        
        case .all:
            // For "all", use the actual data range
            if let firstDate = exerciseStats.maxWeightHistory.first?.date {
                startDate = calendar.startOfDay(for: firstDate)
            } else {
                startDate = calendar.date(byAdding: .day, value: -90, to: today) ?? today
            }
        }
        
        return startDate...today
    }
    
    // MARK: - Helper Methods
    
    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
}

// MARK: - Time Range Button

struct TimeRangeButton: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.futuraSubheadline())
                .foregroundColor(isSelected ? .black : .white)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(isSelected ? Color.white : Color.gray.opacity(0.2))
                .cornerRadius(8)
        }
    }
}

#Preview {
    ExerciseDetailView(
        exerciseStats: ExerciseStats(
            exerciseName: "Bench Press",
            personalBest: PersonalBest(weight: 225, reps: 5, date: Date()),
            totalWorkouts: 12,
            lastPerformed: Date(),
            maxWeightHistory: [
                DataPoint(date: Date().addingTimeInterval(-86400 * 30), value: 185),
                DataPoint(date: Date().addingTimeInterval(-86400 * 20), value: 205),
                DataPoint(date: Date().addingTimeInterval(-86400 * 10), value: 215),
                DataPoint(date: Date(), value: 225)
            ],
            volumeHistory: [
                DataPoint(date: Date().addingTimeInterval(-86400 * 30), value: 5550),
                DataPoint(date: Date().addingTimeInterval(-86400 * 20), value: 6150),
                DataPoint(date: Date().addingTimeInterval(-86400 * 10), value: 6450),
                DataPoint(date: Date(), value: 6750)
            ]
        )
    )
}
