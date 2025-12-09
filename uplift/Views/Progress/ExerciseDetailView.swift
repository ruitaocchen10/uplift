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
                    BackButton{(
                        dismiss()
                    )}
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
            
            if filteredMaxWeightData.isEmpty {
                emptyChartView
            } else {
                Chart(filteredMaxWeightData) { dataPoint in
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
                    AxisMarks(values: generateXAxisValues(dataPoints: filteredMaxWeightData, timeRange: selectedTimeRange)) { value in
                        if let date = value.as(Date.self) {
                            AxisValueLabel {
                                Text(formatXAxisLabel(date: date, timeRange: selectedTimeRange))
                                    .font(.futuraCaption())
                                    .foregroundStyle(Color.gray)
                            }
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
            
            if filteredVolumeData.isEmpty {
                emptyChartView
            } else {
                Chart(filteredVolumeData) { dataPoint in
                    BarMark(
                        x: .value("Date", dataPoint.date),
                        y: .value("Volume", dataPoint.value)
                    )
                    .foregroundStyle(Color.green)
                }
                .chartXScale(domain: getXAxisDomain(timeRange: selectedTimeRange))
                .chartXAxis {
                    AxisMarks(values: generateXAxisValues(dataPoints: filteredVolumeData, timeRange: selectedTimeRange)) { value in
                        if let date = value.as(Date.self) {
                            AxisValueLabel {
                                Text(formatXAxisLabel(date: date, timeRange: selectedTimeRange))
                                    .font(.futuraCaption())
                                    .foregroundStyle(Color.gray)
                            }
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
    
    // MARK: - Empty Chart View
    
    private var emptyChartView: some View {
        VStack(spacing: 12) {
            Image(systemName: "chart.xyaxis.line")
                .font(.system(size: 40))
                .foregroundColor(.gray)
            
            Text("No data for this time range")
                .font(.futuraBody())
                .foregroundColor(.gray)
        }
        .frame(height: 200)
        .frame(maxWidth: .infinity)
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
    
    // MARK: - X-Axis Helpers
    
    /// Calculate how often to show X-axis labels based on time range
    private func calculateXAxisStride(timeRange: ProgressCalculations.TimeRange, dataPoints: [DataPoint]) -> (stride: Calendar.Component, value: Int) {
        guard !dataPoints.isEmpty else { return (.day, 1) }
        
        switch timeRange {
        case .sevenDays:
            return (.day, 1)  // Show every day
        
        case .thirtyDays:
            return (.day, 5)  // Show every 5 days (~6 labels)
        
        case .ninetyDays:
            return (.day, 15) // Show every 15 days (~6 labels)
        
        case .all:
            // Calculate based on actual data range
            let calendar = Calendar.current
            let daysBetween = calendar.dateComponents([.day],
                from: dataPoints.first!.date,
                to: dataPoints.last!.date
            ).day ?? 1
            
            if daysBetween < 90 {
                return (.day, max(1, daysBetween / 6))
            } else if daysBetween < 365 {
                return (.month, 1)  // Monthly
            } else {
                return (.month, 3)  // Quarterly
            }
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
    
    /// Generate specific X-axis date values
    private func generateXAxisValues(dataPoints: [DataPoint], timeRange: ProgressCalculations.TimeRange) -> [Date] {
        let calendar = Calendar.current
        let today = Date()
        
        // Calculate start date based on time range
        let startDate: Date
        switch timeRange {
        case .sevenDays:
            startDate = calendar.date(byAdding: .day, value: -6, to: today) ?? today
        case .thirtyDays:
            startDate = calendar.date(byAdding: .day, value: -29, to: today) ?? today
        case .ninetyDays:
            startDate = calendar.date(byAdding: .day, value: -89, to: today) ?? today
        case .all:
            // Use actual data range if "all" is selected
            if let firstDataPoint = dataPoints.first?.date {
                startDate = firstDataPoint
            } else {
                startDate = calendar.date(byAdding: .day, value: -89, to: today) ?? today
            }
        }
        
        let endDate = today
        
        // Get stride for this time range
        let (strideComponent, strideValue) = calculateXAxisStride(timeRange: timeRange, dataPoints: dataPoints)
        
        var dates: [Date] = []
        var currentDate = calendar.startOfDay(for: startDate)
        let finalDate = calendar.startOfDay(for: endDate)
        
        // Always include start date
        dates.append(currentDate)
        
        // Generate intermediate dates
        while currentDate < finalDate {
            if let nextDate = calendar.date(byAdding: strideComponent, value: strideValue, to: currentDate) {
                if nextDate <= finalDate {
                    dates.append(nextDate)
                }
                currentDate = nextDate
            } else {
                break
            }
        }
        
        // Always include end date if not already included
        if let lastDate = dates.last, !calendar.isDate(lastDate, inSameDayAs: finalDate) {
            dates.append(finalDate)
        }
        
        return dates
    }
    
    private func getXAxisDomain(timeRange: ProgressCalculations.TimeRange) -> ClosedRange<Date> {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        
        let startDate: Date
        switch timeRange {
        case .sevenDays:
            startDate = calendar.date(byAdding: .day, value: -6, to: today) ?? today
        case .thirtyDays:
            startDate = calendar.date(byAdding: .day, value: -29, to: today) ?? today
        case .ninetyDays:
            startDate = calendar.date(byAdding: .day, value: -89, to: today) ?? today
        case .all:
            // For "all", we'll use 90 days as default if no data
            startDate = calendar.date(byAdding: .day, value: -89, to: today) ?? today
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
