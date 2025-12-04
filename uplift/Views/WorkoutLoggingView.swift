//
//  WorkoutLoggingView.swift
//  uplift
//
//  Created by Ruitao Chen on 12/4/25.
//

import SwiftUI
import SwiftData

struct WorkoutLoggingView: View {
    var workout: WorkoutSession
    @Environment(\.dismiss) var dismiss
    @Environment(\.modelContext) private var modelContext
    
    @State private var showingFinishConfirmation = false
    @State private var showingCancelConfirmation = false
    @State private var showingAddExercise = false
    
    private var shouldAutoComplete: Bool {
        workout.isInPast
    }
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header
                headerView
                
                // Exercise List
                ScrollView {
                    VStack(spacing: 12) {
                        ForEach(workout.exercises) { exercise in
                            ExerciseCardView(
                                exercise: exercise,
                                onDelete: {
                                    if let index = workout.exercises.firstIndex(where: { $0.id == exercise.id }) {
                                        workout.exercises.remove(at: index)
                                    }
                                }
                            )
                        }
                        
                        // Add Exercise Button
                        Button(action: {
                            showingAddExercise = true
                        }) {
                            HStack {
                                Image(systemName: "plus.circle.fill")
                                    .font(.futuraTitle3())
                                Text("Add Exercise")
                                    .font(.futuraHeadline())
                            }
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.gray.opacity(0.2))
                            .cornerRadius(12)
                        }
                        .padding(.horizontal)
                    }
                    .padding(.vertical)
                }
                
                // Finish Workout Button
                finishWorkoutButton
            }
        }
        .navigationBarBackButtonHidden(true)
        .sheet(isPresented: $showingAddExercise) {
            AddExerciseSheet { exerciseName in
                let newExercise = Exercise(
                    name: exerciseName,
                    sets: [WorkoutSet()],
                    isExpanded: true
                )
                workout.exercises.append(newExercise)
            }
        }
    }
    
    // MARK: - Header View
    
    private var headerView: some View {
        VStack(spacing: 8) {
            HStack {
                Button(action: {
                    dismiss()
                }) {
                    Image(systemName: "chevron.left")
                        .font(.futuraTitle3())
                        .foregroundColor(.white)
                }
                
                Spacer()
                
                VStack(spacing: 4) {
                    Text(workout.templateName ?? "Workout")
                        .font(.futuraHeadline())
                        .foregroundColor(.white)
                    
                    Text("\(workout.completedSets)/\(workout.totalSets) sets")
                        .font(.futuraCaption())
                        .foregroundColor(.gray)
                }
                
                Spacer()
                
                Button(action: {
                    showingCancelConfirmation = true
                }) {
                    Image(systemName: "ellipsis")
                        .font(.futuraTitle3())
                        .foregroundColor(.white)
                }
            }
            .padding(.horizontal)
            .padding(.top, 8)
            
            // Progress bar
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    Rectangle()
                        .fill(Color.gray.opacity(0.3))
                        .frame(height: 4)
                    
                    Rectangle()
                        .fill(Color.white)
                        .frame(width: geometry.size.width * workout.progressPercentage, height: 4)
                }
            }
            .frame(height: 4)
            .padding(.horizontal)
        }
        .padding(.bottom, 12)
        .background(Color.black)
        .alert("Cancel Workout?", isPresented: $showingCancelConfirmation) {
            Button("Keep Editing", role: .cancel) {}
            Button("Discard Workout", role: .destructive) {
                dismiss()
            }
        } message: {
            Text("This will discard all your progress.")
        }
    }
    
    // MARK: - Finish Workout Button
    
    private var finishWorkoutButton: some View {
        Button(action: {
            if shouldAutoComplete {
                workout.isCompleted = true
                try? modelContext.save()
                dismiss()
            } else {
                showingFinishConfirmation = true
            }
        }) {
            Text("Finish Workout")
                .font(.futuraHeadline())
                .foregroundColor(.black)
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.white)
                .cornerRadius(12)
        }
        .padding()
        .background(Color.black)
        .alert("Finish Workout?", isPresented: $showingFinishConfirmation) {
            Button("Cancel", role: .cancel) {}
            Button("Finish") {
                workout.isCompleted = true
                try? modelContext.save()
                dismiss()
            }
        } message: {
            Text("You completed \(workout.completedSets) of \(workout.totalSets) sets.")
        }
    }
}

// MARK: - Exercise Card View

struct ExerciseCardView: View {
    var exercise: Exercise
    let onDelete: () -> Void
    @Environment(\.modelContext) private var modelContext
    
    @State private var showingDeleteConfirmation = false
    @State private var refreshID = UUID()
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Exercise Header
            Button(action: {
                exercise.isExpanded.toggle()
                refreshID = UUID()
            }) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(exercise.name)
                            .font(.futuraHeadline())
                            .foregroundColor(.white)
                        
                        Text("\(exercise.completedSetsCount)/\(exercise.totalSets) sets")
                            .font(.futuraCaption())
                            .foregroundColor(.gray)
                    }
                    
                    Spacer()
                    
                    Image(systemName: exercise.isExpanded ? "chevron.up" : "chevron.down")
                        .foregroundColor(.white)
                        .font(.futuraSubheadline())
                }
                .padding()
                .background(Color.gray.opacity(0.2))
            }
            
            // Expanded Content
            if exercise.isExpanded {
                VStack(spacing: 8) {
                    // Set rows
                    ForEach(Array(exercise.sets.enumerated()), id: \.element.id) { index, set in
                        SetRowView(
                            setNumber: index + 1,
                            set: set,
                            onDelete: {
                                guard exercise.sets.count > 1 else { return }
                                exercise.sets.remove(at: index)
                                refreshID = UUID()
                            }
                        )
                    }
                    
                    // Add Set Button
                    Button(action: {
                        let lastSet = exercise.sets.last
                        let newSet = WorkoutSet(
                            weight: lastSet?.weight ?? 0,
                            reps: lastSet?.reps ?? 0,
                            isCompleted: false
                        )
                        exercise.sets.append(newSet)
                        refreshID = UUID()
                    }) {
                        HStack {
                            Image(systemName: "plus.circle.fill")
                            Text("Add Set")
                        }
                        .font(.futuraSubheadline())
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)
                        .background(Color.black)
                        .cornerRadius(8)
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 8)
                    
                    // Delete Exercise Button
                    Button(action: {
                        showingDeleteConfirmation = true
                    }) {
                        Text("Delete Exercise")
                            .font(.futuraSubheadline())
                            .foregroundColor(.red)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 8)
                    }
                    .padding(.horizontal)
                }
                .padding(.bottom, 8)
                .background(Color.gray.opacity(0.2))
            }
        }
        .id(refreshID)
        .cornerRadius(12)
        .padding(.horizontal)
        .alert("Delete Exercise?", isPresented: $showingDeleteConfirmation) {
            Button("Cancel", role: .cancel) {}
            Button("Delete", role: .destructive) {
                onDelete()
            }
        } message: {
            Text("This will remove \(exercise.name) from your workout.")
        }
    }
}

// MARK: - Set Row View

struct SetRowView: View {
    let setNumber: Int
    var set: WorkoutSet
    let onDelete: () -> Void
    @Environment(\.modelContext) private var modelContext
    
    @FocusState private var focusedField: Field?
    @State private var showingDeleteConfirmation = false
    @State private var localWeight: Double
    @State private var localReps: Int
    @State private var localCompleted: Bool
    
    init(setNumber: Int, set: WorkoutSet, onDelete: @escaping () -> Void) {
        self.setNumber = setNumber
        self.set = set
        self.onDelete = onDelete
        _localWeight = State(initialValue: set.weight)
        _localReps = State(initialValue: set.reps)
        _localCompleted = State(initialValue: set.isCompleted)
    }
    
    enum Field {
        case weight, reps
    }
    
    var body: some View {
        HStack(spacing: 12) {
            // Set number
            Text("\(setNumber)")
                .font(.futuraBody())
                .foregroundColor(.gray)
                .frame(width: 30)
            
            // Weight input with steppers
            HStack(spacing: 4) {
                Button(action: {
                    localWeight = max(0, localWeight - 5)
                    set.weight = localWeight
                }) {
                    Image(systemName: "minus.circle.fill")
                        .foregroundColor(.white)
                        .font(.futuraBody())
                }
                
                TextField("0", value: $localWeight, format: .number)
                    .font(.futuraBody())
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .keyboardType(.numberPad)
                    .focused($focusedField, equals: .weight)
                    .frame(width: 50)
                    .onChange(of: localWeight) { oldValue, newValue in
                        set.weight = newValue
                    }
                
                Button(action: {
                    localWeight += 5
                    set.weight = localWeight
                }) {
                    Image(systemName: "plus.circle.fill")
                        .foregroundColor(.white)
                        .font(.futuraBody())
                }
                
                Text("lbs")
                    .font(.futuraCaption())
                    .foregroundColor(.gray)
            }
            .frame(maxWidth: .infinity)
            
            // Reps input with steppers
            HStack(spacing: 4) {
                Button(action: {
                    localReps = max(0, localReps - 1)
                    set.reps = localReps
                }) {
                    Image(systemName: "minus.circle.fill")
                        .foregroundColor(.white)
                        .font(.futuraBody())
                }
                
                TextField("0", value: $localReps, format: .number)
                    .font(.futuraBody())
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .keyboardType(.numberPad)
                    .focused($focusedField, equals: .reps)
                    .frame(width: 40)
                    .onChange(of: localReps) { oldValue, newValue in
                        set.reps = newValue
                    }
                
                Button(action: {
                    localReps += 1
                    set.reps = localReps
                }) {
                    Image(systemName: "plus.circle.fill")
                        .foregroundColor(.white)
                        .font(.futuraBody())
                }
            }
            .frame(maxWidth: .infinity)
            
            // Completion checkmark
            Button(action: {
                localCompleted.toggle()
                set.isCompleted = localCompleted
            }) {
                Image(systemName: localCompleted ? "checkmark.circle.fill" : "circle")
                    .foregroundColor(localCompleted ? .green : .gray)
                    .font(.futuraTitle3())
            }
            
            // Delete set button
            Button(action: {
                showingDeleteConfirmation = true
            }) {
                Image(systemName: "trash")
                    .foregroundColor(.red)
                    .font(.futuraBody())
            }
            .alert("Delete Set?", isPresented: $showingDeleteConfirmation) {
                Button("Cancel", role: .cancel) {}
                Button("Delete", role: .destructive) {
                    onDelete()
                }
            } message: {
                Text("Remove this set from the exercise?")
            }
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
        .background(localCompleted ? Color.green.opacity(0.1) : Color.clear)
    }
}

// MARK: - Add Exercise Sheet

struct AddExerciseSheet: View {
    @Environment(\.dismiss) var dismiss
    let onAdd: (String) -> Void
    
    @State private var searchText = ""
    
    private let commonExercises = [
        "Bench Press", "Squat", "Deadlift", "Overhead Press",
        "Barbell Row", "Pull-ups", "Dips", "Bicep Curls",
        "Tricep Extensions", "Leg Press", "Leg Curls", "Leg Extensions",
        "Lat Pulldown", "Cable Rows", "Face Pulls", "Lateral Raises",
        "Front Raises", "Rear Delt Fly", "Romanian Deadlift", "Lunges"
    ].sorted()
    
    private var filteredExercises: [String] {
        if searchText.isEmpty {
            return commonExercises
        }
        return commonExercises.filter { $0.localizedCaseInsensitiveContains(searchText) }
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.black.ignoresSafeArea()
                
                VStack(spacing: 0) {
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.gray)
                        
                        TextField("Search exercises", text: $searchText)
                            .font(.futuraBody())
                            .foregroundColor(.white)
                            .autocapitalization(.words)
                    }
                    .padding()
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(12)
                    .padding()
                    
                    ScrollView {
                        VStack(spacing: 8) {
                            ForEach(filteredExercises, id: \.self) { exercise in
                                Button(action: {
                                    onAdd(exercise)
                                    dismiss()
                                }) {
                                    HStack {
                                        Text(exercise)
                                            .font(.futuraBody())
                                            .foregroundColor(.white)
                                        Spacer()
                                        Image(systemName: "plus.circle")
                                            .foregroundColor(.white)
                                    }
                                    .padding()
                                    .background(Color.gray.opacity(0.2))
                                    .cornerRadius(12)
                                }
                            }
                            
                            if !searchText.isEmpty && !commonExercises.contains(searchText) {
                                Button(action: {
                                    onAdd(searchText)
                                    dismiss()
                                }) {
                                    HStack {
                                        Text("Add \"\(searchText)\"")
                                            .font(.futuraBody())
                                            .foregroundColor(.white)
                                        Spacer()
                                        Image(systemName: "plus.circle.fill")
                                            .foregroundColor(.green)
                                    }
                                    .padding()
                                    .background(Color.green.opacity(0.2))
                                    .cornerRadius(12)
                                }
                            }
                        }
                        .padding(.horizontal)
                        .padding(.bottom, 20)
                    }
                }
            }
            .navigationTitle("Add Exercise")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(.white)
                }
            }
        }
    }
}

#Preview {
    WorkoutLoggingView(workout: DummyData.activeWorkout)
}
