//
//  HomeView.swift
//  uplift
//
//  Created by Ruitao Chen on 12/3/25.
//

import SwiftUI

struct HomeView: View {
    @State private var selectedDate = Date()
    @State private var showingTemplateSelector = false
    @State private var showingFullCalendar = false
    @State private var showingWorkoutDetail: WorkoutSession?
    @State private var workoutToEdit: WorkoutSession?
    @State private var workoutToDelete: WorkoutSession?
    @State private var showingDeleteConfirmation = false
    
    @EnvironmentObject var workoutManager: WorkoutManager
    
    // Filter workouts for selected date
    private var workoutsForSelectedDate: [WorkoutSession] {
        workoutManager.workouts(for: selectedDate)
    }
    
    private var completedWorkouts: [WorkoutSession] {
        workoutsForSelectedDate.filter { $0.isCompleted }
    }
    
    private var scheduledWorkouts: [WorkoutSession] {
        workoutsForSelectedDate.filter { $0.isScheduled }
    }
    
    private var inProgressWorkouts: [WorkoutSession] {
        workoutsForSelectedDate.filter { $0.isInProgress }
    }
    
    private var notStartedTodayWorkouts: [WorkoutSession] {
        workoutsForSelectedDate.filter { !$0.isCompleted && $0.isToday && !$0.hasStarted }
    }
    
    private var hasWorkoutsOnSelectedDate: Bool {
        !workoutsForSelectedDate.isEmpty
    }
    
    private var isSelectedDateToday: Bool {
        Calendar.current.isDateInToday(selectedDate)
    }
    
    private var isSelectedDateFuture: Bool {
        Calendar.current.startOfDay(for: selectedDate) > Calendar.current.startOfDay(for: Date())
    }
    
    private var isSelectedDatePast: Bool {
        Calendar.current.startOfDay(for: selectedDate) < Calendar.current.startOfDay(for: Date())
    }
    
    private var datesWithWorkouts: Set<Date> {
        workoutManager.workoutDates()
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.black.ignoresSafeArea()
                
                VStack(alignment: .leading, spacing: 24) {
                    // Calendar Week View with Navigation
                    calendarSection
                    
                    // Content based on selected date
                    ScrollView {
                        workoutListContent
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    UserInitialsButton(initials: "RC", action: nil)
                }
                
                ToolbarItem(placement: .principal) {
                    HeaderTitle(
                        title: "Ruitao Chen",
                        subtitle: "Welcome back"
                    )
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    SearchButton {
                        // TODO: Implement search
                    }
                }
            }
            .standardToolbar()
            .sheet(isPresented: $showingTemplateSelector) {
                TemplateSelectionSheet(
                    templates: workoutManager.templates,
                    selectedDate: selectedDate,
                    isToday: isSelectedDateToday,
                    isFuture: isSelectedDateFuture,
                    isPast: isSelectedDatePast,
                    onTemplateSelected: { template in
                        handleTemplateSelection(template)
                    }
                )
            }
            .sheet(isPresented: $showingFullCalendar) {
                FullCalendarPicker(selectedDate: $selectedDate)
            }
            .sheet(item: $showingWorkoutDetail) { workout in
                WorkoutDetailSheet(workout: workout)
            }
            .alert("Delete Workout?", isPresented: $showingDeleteConfirmation) {
                Button("Cancel", role: .cancel) {
                    workoutToDelete = nil
                }
                Button("Delete", role: .destructive) {
                    if let workout = workoutToDelete {
                        Task {
                            await workoutManager.deleteWorkout(workout)
                        }
                    }
                    workoutToDelete = nil
                }
            } message: {
                if let workout = workoutToDelete {
                    if workout.isCompleted {
                        Text("This will permanently delete \"\(workout.templateName ?? "Workout")\" and all its data.")
                    } else {
                        Text("This will remove \"\(workout.templateName ?? "Workout")\" from your schedule.")
                    }
                }
            }
            .fullScreenCover(item: $workoutToEdit) { workout in
                if let index = workoutManager.workouts.firstIndex(where: { $0.id == workout.id }) {
                    NavigationStack {
                        WorkoutLoggingView(workout: workoutManager.workouts[index])
                    }
                }
            }
        }
    }

    // MARK: - Workout List Content

    private var workoutListContent: some View {
        VStack(spacing: 16) {
            // Show completed workouts
            if !completedWorkouts.isEmpty {
                ForEach(completedWorkouts) { workout in
                    CompletedWorkoutCard(workout: workout)
                        .onTapGesture {
                            showingWorkoutDetail = workout
                        }
                        .contextMenu {
                            Button(role: .destructive) {
                                workoutToDelete = workout
                                showingDeleteConfirmation = true
                            } label: {
                                Label("Delete Workout", systemImage: "trash")
                            }
                        }
                }
            }
            
            // Show scheduled workouts (future)
            if !scheduledWorkouts.isEmpty {
                ForEach(scheduledWorkouts) { workout in
                    ScheduledWorkoutCard(workout: workout, onStart: {
                        if let index = workoutManager.workouts.firstIndex(where: { $0.id == workout.id }) {
                            workoutToEdit = workoutManager.workouts[index]
                        }
                    })
                        .onTapGesture {
                            if let index = workoutManager.workouts.firstIndex(where: { $0.id == workout.id }) {
                                workoutToEdit = workoutManager.workouts[index]
                            }
                        }
                        .contextMenu {
                            Button(role: .destructive) {
                                workoutToDelete = workout
                                showingDeleteConfirmation = true
                            } label: {
                                Label("Delete Workout", systemImage: "trash")
                            }
                        }
                }
            }
            
            // Show in-progress workouts
            if !inProgressWorkouts.isEmpty {
                ForEach(inProgressWorkouts) { workout in
                    InProgressWorkoutCard(workout: workout, onResume: {
                        if let index = workoutManager.workouts.firstIndex(where: { $0.id == workout.id }) {
                            workoutToEdit = workoutManager.workouts[index]
                        }
                    })
                        .onTapGesture {
                            if let index = workoutManager.workouts.firstIndex(where: { $0.id == workout.id }) {
                                workoutToEdit = workoutManager.workouts[index]
                            }
                        }
                        .contextMenu {
                            Button(role: .destructive) {
                                workoutToDelete = workout
                                showingDeleteConfirmation = true
                            } label: {
                                Label("Delete Workout", systemImage: "trash")
                            }
                        }
                }
            }
            
            // Show not started today workouts
            if !notStartedTodayWorkouts.isEmpty {
                ForEach(notStartedTodayWorkouts) { workout in
                    NotStartedTodayCard(workout: workout, onStart: {
                        if let index = workoutManager.workouts.firstIndex(where: { $0.id == workout.id }) {
                            workoutToEdit = workoutManager.workouts[index]
                        }
                    })
                        .onTapGesture {
                            if let index = workoutManager.workouts.firstIndex(where: { $0.id == workout.id }) {
                                workoutToEdit = workoutManager.workouts[index]
                            }
                        }
                        .contextMenu {
                            Button(role: .destructive) {
                                workoutToDelete = workout
                                showingDeleteConfirmation = true
                            } label: {
                                Label("Delete Workout", systemImage: "trash")
                            }
                        }
                }
            }
            
            // Show appropriate empty state or add button
            if !hasWorkoutsOnSelectedDate {
                EmptyDateView(
                    isToday: isSelectedDateToday,
                    isFuture: isSelectedDateFuture,
                    isPast: isSelectedDatePast,
                    onAddWorkout: {
                        showingTemplateSelector = true
                    }
                )
            } else {
                addAnotherWorkoutButton
            }
        }
        .padding(.horizontal)
        .padding(.bottom, 20)
    }

    private var addAnotherWorkoutButton: some View {
        ActionButton(
            title: addWorkoutButtonText,
            icon: "plus.circle",
            style: .secondary
        ) {
            showingTemplateSelector = true
        }
    }
    
    // MARK: - View Components
    
    private var calendarSection: some View {
        VStack(spacing: 12) {
            // Month/Year header with arrows on the right
            HStack {
                Button(action: {
                    showingFullCalendar = true
                }) {
                    HStack(spacing: 6) {
                        Text(monthYearString)
                            .font(.futuraTitle3())
                            .foregroundColor(.white)
                        
                        Image(systemName: "calendar")
                            .font(.futuraCaption())
                            .foregroundColor(.gray)
                    }
                }
                
                Spacer()
                
                // Navigation arrows on the right
                HStack(spacing: 16) {
                    Button(action: previousWeek) {
                        Image(systemName: "chevron.left")
                            .foregroundColor(.white)
                            .font(.futuraBody())
                    }
                    
                    Button(action: nextWeek) {
                        Image(systemName: "chevron.right")
                            .foregroundColor(.white)
                            .font(.futuraBody())
                    }
                }
            }
            .padding(.horizontal)
            
            // Week view with swipe gesture
            CalendarWeekView(
                selectedDate: $selectedDate,
                datesWithWorkouts: datesWithWorkouts
            )
            .gesture(
                DragGesture(minimumDistance: 50)
                    .onEnded { value in
                        if value.translation.width < 0 {
                            // Swiped left - next week
                            nextWeek()
                        } else if value.translation.width > 0 {
                            // Swiped right - previous week
                            previousWeek()
                        }
                    }
            )
        }
        .padding(.vertical)
    }
    
    // MARK: - Helper Methods
    
    private var addWorkoutButtonText: String {
        if isSelectedDateFuture {
            return "Schedule Another Workout"
        } else if isSelectedDateToday {
            return "Add Another Workout"
        } else {
            return "Add Missing Workout"
        }
    }
    
    private var monthYearString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter.string(from: selectedDate)
    }
    
    private func previousWeek() {
        selectedDate = Calendar.current.date(byAdding: .weekOfYear, value: -1, to: selectedDate) ?? selectedDate
    }
    
    private func nextWeek() {
        selectedDate = Calendar.current.date(byAdding: .weekOfYear, value: 1, to: selectedDate) ?? selectedDate
    }

    private func handleTemplateSelection(_ template: WorkoutTemplate) {
        let newWorkout = WorkoutSession.fromTemplate(template, date: selectedDate)
        Task {
            await workoutManager.addWorkout(newWorkout)
        }
        
        // For today or past, open workout logging immediately
        if !isSelectedDateFuture {
            if let index = workoutManager.workouts.firstIndex(where: { $0.id == newWorkout.id }) {
                workoutToEdit = workoutManager.workouts[index]
            }
        }
    }
}

// MARK: - Calendar Week View Component

struct CalendarWeekView: View {
    @Binding var selectedDate: Date
    let datesWithWorkouts: Set<Date>
    
    private let calendar = Calendar.current
    
    // Get the week dates starting from Sunday
    private var weekDates: [Date] {
        let weekday = calendar.component(.weekday, from: selectedDate)
        let daysToSubtract = weekday - 1
        
        guard let weekStart = calendar.date(byAdding: .day, value: -daysToSubtract, to: selectedDate) else {
            return []
        }
        
        var dates: [Date] = []
        for i in 0..<7 {
            if let date = calendar.date(byAdding: .day, value: i, to: weekStart) {
                dates.append(date)
            }
        }
        
        return dates
    }
    
    var body: some View {
        HStack(spacing: 8) {
            ForEach(weekDates, id: \.self) { date in
                let dayOfWeek = calendar.component(.weekday, from: date)
                let dayNumber = calendar.component(.day, from: date)
                let isSelected = calendar.isDate(date, inSameDayAs: selectedDate)
                let isToday = calendar.isDateInToday(date)
                let hasWorkout = datesWithWorkouts.contains(calendar.startOfDay(for: date))
                
                VStack(spacing: 8) {
                    // Day of week label
                    Text(weekdaySymbol(for: dayOfWeek))
                        .font(.futuraCaption())
                        .foregroundColor(isSelected ? .white : .gray)
                    
                    // Date card
                    ZStack {
                        // Subtle background for today (behind everything)
                        if isToday && !isSelected {
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color.gray.opacity(0.15))
                                .frame(width: 44, height: 56)
                        }
                        
                        if isSelected {
                            // Selected date - large white rounded rectangle
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color.white)
                                .frame(width: 50, height: 64)
                            
                            Text("\(dayNumber)")
                                .font(.futuraTitle2())
                                .foregroundColor(.black)
                        } else {
                            // Unselected date - with fade-edge gradient border
                            ZStack {
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color.clear)
                                    .frame(width: 44, height: 56)
                                    .fadeEdgeBorder(
                                        color: .gray,
                                        cornerRadius: 12,
                                        lineWidth: 1,
                                        fadeStyle: .horizontal
                                    )
                                
                                Text("\(dayNumber)")
                                    .font(.futuraBody())
                                    .foregroundColor(.white)
                            }
                        }
                        
                        // Workout indicator dot
                        if hasWorkout && !isSelected {
                            Circle()
                                .fill(Color.green)
                                .frame(width: 4, height: 4)
                                .offset(x: 15, y: -20)
                        }
                    }
                }
                .frame(maxWidth: .infinity)
                .onTapGesture {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        selectedDate = date
                    }
                }
            }
        }
        .padding(.horizontal)
    }
    
    private func weekdaySymbol(for weekday: Int) -> String {
        let symbols = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]
        return symbols[weekday - 1]
    }
}

// MARK: - Workout Cards

struct CompletedWorkoutCard: View {
    let workout: WorkoutSession
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(workout.templateName ?? "Workout")
                        .font(.futuraHeadline())
                        .foregroundColor(.white)
                    
                    HStack(spacing: 12) {
                        Label("\(workout.exercises.count) exercises", systemImage: "figure.strengthtraining.traditional")
                        Label("\(Int(workout.totalVolume)) lbs", systemImage: "scalemass")
                    }
                    .font(.futuraCaption())
                    .foregroundColor(.gray)
                }
                
                Spacer()
                
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(.green)
                    .font(.futuraTitle3())
            }
            
            Text("Tap to view details")
                .font(.futuraCaption())
                .foregroundColor(.gray)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.gray.opacity(0.2))
        )
        // VERSION 1: Radial glow effect
        .fadeEdgeBorder(
            color: .white,
            cornerRadius: 16,
            lineWidth: 1,
            fadeStyle: .radial
        )
    }
}

struct ScheduledWorkoutCard: View {
    let workout: WorkoutSession
    let onStart: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(workout.templateName ?? "Workout")
                        .font(.futuraHeadline())
                        .foregroundColor(.white)
                    
                    Text("Scheduled for \(formattedDate)")
                        .font(.futuraCaption())
                        .foregroundColor(.white.opacity(0.8))
                }
                
                Spacer()
                
                Image(systemName: "calendar")
                    .foregroundColor(.blue)
                    .font(.futuraTitle3())
            }
            
            Text("Tap to view details")
                .font(.futuraCaption())
                .foregroundColor(.gray)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(red: 0.1, green: 0.2, blue: 0.3))
        )
        // VERSION 1: Radial glow effect
        .fadeEdgeBorder(
            color: .white,
            cornerRadius: 16,
            lineWidth: 1,
            fadeStyle: .radial
        )
    }
    
    private var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: workout.date)
    }
}

struct InProgressWorkoutCard: View {
    let workout: WorkoutSession
    let onResume: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(workout.templateName ?? "Workout")
                        .font(.futuraHeadline())
                        .foregroundColor(.white)
                    
                    Text("Ready to start")
                        .font(.futuraCaption())
                        .foregroundColor(.white.opacity(0.8))
                }
                
                Spacer()

                Image(systemName: "play.circle.fill")
                    .foregroundColor(.orange)
                    .font(.futuraTitle3())
            }
            
            Text("Tap to view details")
                .font(.futuraCaption())
                .foregroundColor(.gray)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(red: 0.3, green: 0.2, blue: 0.15))
        )
        .fadeEdgeBorder(
            color: .white,
            cornerRadius: 16,
            lineWidth: 1,
            fadeStyle: .radial
        )
    }
}

struct NotStartedTodayCard: View {
    let workout: WorkoutSession
    let onStart: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(workout.templateName ?? "Workout")
                        .font(.futuraHeadline())
                        .foregroundColor(.white)
                    
                    Text("Ready to start")
                        .font(.futuraCaption())
                        .foregroundColor(.white.opacity(0.8))
                }
                
                Spacer()
                
                Image(systemName: "play.circle.fill")
                    .foregroundColor(.green)
                    .font(.futuraTitle3())
            }
            
            Text("Tap to view details")
                .font(.futuraCaption())
                .foregroundColor(.gray)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(red: 0.1, green: 0.25, blue: 0.2))
        )
        .fadeEdgeBorder(
            color: .white,
            cornerRadius: 16,
            lineWidth: 1,
            fadeStyle: .radial
        )
    }
}

struct EmptyDateView: View {
    let isToday: Bool
    let isFuture: Bool
    let isPast: Bool
    let onAddWorkout: () -> Void
    
    private var buttonText: String {
        if isFuture {
            return "Schedule Workout"
        } else if isToday {
            return "Add Workout"
        } else {
            return "Add Missing Workout"
        }
    }
    
    private var iconName: String {
        if isFuture {
            return "calendar.badge.plus"
        } else if isPast {
            return "plus.circle"
        } else {
            return "figure.strengthtraining.traditional"
        }
    }
    
    private var emptyText: String {
        if isPast {
            return "Rest day"
        } else if isFuture {
            return "No workout scheduled"
        } else {
            return "No workout today"
        }
    }
    
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: iconName)
                .font(.system(size: 60))
                .foregroundColor(.gray)
            
            Text(emptyText)
                .font(.futuraHeadline())
                .foregroundColor(.gray)
            
            Spacer()
            
            ActionButton(
                title: buttonText,
                icon: "plus.circle",
                style: .secondary
            ) {
                onAddWorkout()
            }
        }
        .padding(.vertical, 20)
    }
}

// MARK: - Sheet Views

struct TemplateSelectionSheet: View {
    let templates: [WorkoutTemplate]
    let selectedDate: Date
    let isToday: Bool
    let isFuture: Bool
    let isPast: Bool
    let onTemplateSelected: (WorkoutTemplate) -> Void
    
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.black.ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Template List
                    ScrollView {
                        VStack(spacing: 12) {
                            ForEach(templates) { template in
                                Button(action: {
                                    onTemplateSelected(template)
                                    dismiss()
                                }) {
                                    HStack {
                                        VStack(alignment: .leading, spacing: 4) {
                                            Text(template.name)
                                                .font(.futuraHeadline())
                                                .foregroundColor(.white)
                                            
                                            Text("\(template.totalExercises) exercises")
                                                .font(.futuraSubheadline())
                                                .foregroundColor(.gray)
                                        }
                                        
                                        Spacer()
                                        
                                        Image(systemName: "chevron.right")
                                            .foregroundColor(.gray)
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
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                        }
                        .padding()
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    HeaderTitle(
                        title: "Select Template"
                    )
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    CancelButton{(
                        dismiss()
                    )}
                }
            }
            .standardToolbar()
        }
    }
}

struct FullCalendarPicker: View {
    @Binding var selectedDate: Date
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.black.ignoresSafeArea()
                
                DatePicker(
                    "Select Date",
                    selection: $selectedDate,
                    displayedComponents: [.date]
                )
                .datePickerStyle(.graphical)
                .colorScheme(.dark)
                .padding()
            }
            .navigationTitle("Select Date")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    DoneButton {
                        dismiss()
                    }
                }
            }
            .standardToolbar()
        }
    }
}

struct WorkoutDetailSheet: View {
    let workout: WorkoutSession
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.black.ignoresSafeArea()
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        // Workout Info
                        VStack(alignment: .leading, spacing: 8) {
                            Text(workout.templateName ?? "Workout")
                                .font(.futuraTitle2())
                                .foregroundColor(.white)
                            
                            HStack(spacing: 16) {
                                Label("\(workout.exercises.count) exercises", systemImage: "figure.strengthtraining.traditional")
                                Label("\(Int(workout.totalVolume)) lbs", systemImage: "scalemass")
                            }
                            .font(.futuraSubheadline())
                            .foregroundColor(.gray)
                        }
                        .padding(.horizontal)
                        
                        Divider()
                            .background(Color.gray)
                        
                        // Exercises
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Exercises")
                                .font(.futuraHeadline())
                                .foregroundColor(.white)
                                .padding(.horizontal)
                            
                            ForEach(workout.exercises) { exercise in
                                VStack(alignment: .leading, spacing: 8) {
                                    Text(exercise.name)
                                        .font(.futuraHeadline())
                                        .foregroundColor(.white)
                                    
                                    ForEach(Array(exercise.sets.enumerated()), id: \.element.id) { index, set in
                                        HStack {
                                            Text("Set \(index + 1)")
                                                .font(.futuraBody())
                                                .foregroundColor(.gray)
                                            
                                            Spacer()
                                            
                                            Text("\(Int(set.weight)) lbs × \(set.reps) reps")
                                                .font(.futuraBody())
                                                .foregroundColor(.white)
                                            
                                            if set.isCompleted {
                                                Image(systemName: "checkmark.circle.fill")
                                                    .foregroundColor(.green)
                                            }
                                        }
                                    }
                                }
                                .padding()
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(Color.gray.opacity(0.2))
                                )
                                .fadeEdgeBorder(
                                    color: .white.opacity(0.4),
                                    cornerRadius: 12,
                                    lineWidth: 1,
                                    fadeStyle: .radial
                                )
                                .padding(.horizontal)
                            }
                        }
                    }
                    .padding(.vertical)
                }
            }
            .navigationTitle("Workout Details")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    DoneButton {
                        dismiss()
                    }
                }
            }
            .standardToolbar()
        }
    }
}

#Preview {
    HomeView()
}
