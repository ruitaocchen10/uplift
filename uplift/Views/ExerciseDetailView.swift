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
            .navigationTitle(exerciseStats.exerciseName)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        dismiss()
                    }) {
                        Image(systemName: "chevron.left")
                            .foregroundColor(.white)
                    }
                }
            }
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
                .chartXAxis {
                    AxisMarks(values: .automatic) { _ in
                        AxisValueLabel()
                            .foregroundStyle(Color.gray)
                            .font(.futuraCaption())
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
                .chartXAxis {
                    AxisMarks(values: .automatic) { _ in
                        AxisValueLabel()
                            .foregroundStyle(Color.gray)
                            .font(.futuraCaption())
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
