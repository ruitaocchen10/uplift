//
//  WorkoutLoggingView.swift
//  uplift
//
//  Created by Ruitao Chen on 12/3/25.
//

import SwiftUI

struct WorkoutLoggingView: View {
    @State private var currentSession: WorkoutSession
    @Environment(\.dismiss) var dismiss
    
    @State private var showingFinishConfirmation = false
    @State private var showingCancelConfirmation = false
    @State private var showingAddExercise = false
    @State private var editingExercise: Exercise?
    
    init(session: WorkoutSession = DummyData.activeWorkout) {
        _currentSession = State(initialValue: session)
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
                        ForEach(Array(currentSession.exercises.enumerated()), id: \.element.id) { index, exercise in
                            ExerciseCard(
                                exercise: exercise,
                                onToggleExpansion: {
                                    toggleExerciseExpansion(exercise.id)
                                },
                                onUpdateSet: { set in
                                    updateSet(set, in: exercise.id)
                                },
                                onAddSet: {
                                    addSet(to: exercise.id)
                                },
                                onDeleteSet: { setId in
                                    deleteSet(setId, from: exercise.id)
                                },
                                onToggleSetCompletion: { setId in
                                    toggleSetCompletion(setId, in: exercise.id)
                                },
                                onDelete: {
                                    deleteExercise(exercise)
                                }
                            )
                        }
                        .onMove { source, destination in
                            moveExercise(from: source, to: destination)
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
                addExercise(newExercise)
            }
        }
    }
    
    // MARK: - Header View
    
    private var headerView: some View {
        VStack(spacing: 8) {
            HStack {
                Button(action: {
                    // Just save and exit - workout remains in progress
                    dismiss()
                }) {
                    Image(systemName: "chevron.left")
                        .font(.futuraTitle3())
                        .foregroundColor(.white)
                }
                
                Spacer()
                
                VStack(spacing: 4) {
                    Text(currentSession.templateName ?? "Workout")
                        .font(.futuraHeadline())
                        .foregroundColor(.white)
                    
                    Text("\(currentSession.completedSets)/\(currentSession.totalSets) sets")
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
                        .frame(width: geometry.size.width * currentSession.progressPercentage, height: 4)
                }
            }
            .frame(height: 4)
            .padding(.horizontal)
        }
        .padding(.bottom, 12)
        .background(Color.black)
        .alert("Discard Workout?", isPresented: $showingCancelConfirmation) {
            Button("Cancel", role: .cancel) {}
            Button("Discard Workout", role: .destructive) {
                dismiss()
            }
        } message: {
            Text("This will permanently delete this workout and all your progress.")
        }
    }
    
    // MARK: - Finish Workout Button
    
    private var finishWorkoutButton: some View {
        Button(action: {
            showingFinishConfirmation = true
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
                currentSession.isCompleted = true
                dismiss()
            }
        } message: {
            Text("You completed \(currentSession.completedSets) of \(currentSession.totalSets) sets.")
        }
    }
    
    // MARK: - Helper Methods
    
    private func toggleExerciseExpansion(_ exerciseId: UUID) {
        if let index = currentSession.exercises.firstIndex(where: { $0.id == exerciseId }) {
            currentSession.exercises[index].isExpanded.toggle()
        }
    }
    
    private func updateSet(_ set: WorkoutSet, in exerciseId: UUID) {
        if let exerciseIndex = currentSession.exercises.firstIndex(where: { $0.id == exerciseId }),
           let setIndex = currentSession.exercises[exerciseIndex].sets.firstIndex(where: { $0.id == set.id }) {
            currentSession.exercises[exerciseIndex].sets[setIndex] = set
        }
    }
    
    private func addSet(to exerciseId: UUID) {
        if let index = currentSession.exercises.firstIndex(where: { $0.id == exerciseId }) {
            let lastSet = currentSession.exercises[index].sets.last
            let newSet = WorkoutSet(
                weight: lastSet?.weight ?? 0,
                reps: lastSet?.reps ?? 0,
                isCompleted: false
            )
            currentSession.exercises[index].sets.append(newSet)
        }
    }
    
    private func deleteSet(_ setId: UUID, from exerciseId: UUID) {
        if let exerciseIndex = currentSession.exercises.firstIndex(where: { $0.id == exerciseId }) {
            currentSession.exercises[exerciseIndex].sets.removeAll { $0.id == setId }
        }
    }
    
    private func toggleSetCompletion(_ setId: UUID, in exerciseId: UUID) {
        if let exerciseIndex = currentSession.exercises.firstIndex(where: { $0.id == exerciseId }),
           let setIndex = currentSession.exercises[exerciseIndex].sets.firstIndex(where: { $0.id == setId }) {
            currentSession.exercises[exerciseIndex].sets[setIndex].isCompleted.toggle()
        }
    }
    
    private func addExercise(_ exercise: Exercise) {
        currentSession.exercises.append(exercise)
    }
    
    private func deleteExercise(_ exercise: Exercise) {
        currentSession.exercises.removeAll { $0.id == exercise.id }
    }
    
    private func moveExercise(from source: IndexSet, to destination: Int) {
        currentSession.exercises.move(fromOffsets: source, toOffset: destination)
    }
}

// MARK: - Exercise Card

struct ExerciseCard: View {
    let exercise: Exercise
    let onToggleExpansion: () -> Void
    let onUpdateSet: (WorkoutSet) -> Void
    let onAddSet: () -> Void
    let onDeleteSet: (UUID) -> Void
    let onToggleSetCompletion: (UUID) -> Void
    let onDelete: () -> Void
    
    @State private var showingDeleteConfirmation = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Exercise Header
            Button(action: onToggleExpansion) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(exercise.name)
                            .font(.futuraHeadline())
                            .foregroundColor(.white)
                        
                        Text("\(exercise.sets.count) sets x \(exercise.sets.first?.reps ?? 0)-\(exercise.sets.last?.reps ?? 0) reps")
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
                        SetRow(
                            setNumber: index + 1,
                            set: set,
                            onUpdate: onUpdateSet,
                            onDelete: {
                                onDeleteSet(set.id)
                            },
                            onToggleCompletion: {
                                onToggleSetCompletion(set.id)
                            }
                        )
                    }
                    
                    // Add Set Button
                    Button(action: onAddSet) {
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

// MARK: - Set Row

struct SetRow: View {
    let setNumber: Int
    let set: WorkoutSet
    let onUpdate: (WorkoutSet) -> Void
    let onDelete: () -> Void
    let onToggleCompletion: () -> Void
    
    @State private var weightText: String
    @State private var repsText: String
    @FocusState private var focusedField: Field?
    
    enum Field {
        case weight, reps
    }
    
    init(setNumber: Int, set: WorkoutSet, onUpdate: @escaping (WorkoutSet) -> Void, onDelete: @escaping () -> Void, onToggleCompletion: @escaping () -> Void) {
        self.setNumber = setNumber
        self.set = set
        self.onUpdate = onUpdate
        self.onDelete = onDelete
        self.onToggleCompletion = onToggleCompletion
        
        _weightText = State(initialValue: set.weight > 0 ? "\(Int(set.weight))" : "")
        _repsText = State(initialValue: set.reps > 0 ? "\(set.reps)" : "")
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
                    decrementWeight()
                }) {
                    Image(systemName: "minus.circle.fill")
                        .foregroundColor(.white)
                        .font(.futuraBody())
                }
                
                TextField("0", text: $weightText)
                    .font(.futuraBody())
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .keyboardType(.numberPad)
                    .focused($focusedField, equals: .weight)
                    .frame(width: 50)
                    .onChange(of: weightText) { _, newValue in
                        updateWeight(newValue)
                    }
                
                Button(action: {
                    incrementWeight()
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
                    decrementReps()
                }) {
                    Image(systemName: "minus.circle.fill")
                        .foregroundColor(.white)
                        .font(.futuraBody())
                }
                
                TextField("0", text: $repsText)
                    .font(.futuraBody())
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .keyboardType(.numberPad)
                    .focused($focusedField, equals: .reps)
                    .frame(width: 40)
                    .onChange(of: repsText) { _, newValue in
                        updateReps(newValue)
                    }
                
                Button(action: {
                    incrementReps()
                }) {
                    Image(systemName: "plus.circle.fill")
                        .foregroundColor(.white)
                        .font(.futuraBody())
                }
            }
            .frame(maxWidth: .infinity)
            
            // Completion checkmark
            Button(action: onToggleCompletion) {
                Image(systemName: set.isCompleted ? "checkmark.circle.fill" : "circle")
                    .foregroundColor(set.isCompleted ? .green : .gray)
                    .font(.futuraTitle3())
            }
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
        .background(set.isCompleted ? Color.green.opacity(0.1) : Color.clear)
    }
    
    // MARK: - Helper Methods
    
    private func incrementWeight() {
        let currentWeight = Double(weightText) ?? set.weight
        let newWeight = currentWeight + 5
        weightText = "\(Int(newWeight))"
        updateSet(weight: newWeight, reps: set.reps)
    }
    
    private func decrementWeight() {
        let currentWeight = Double(weightText) ?? set.weight
        let newWeight = max(0, currentWeight - 5)
        weightText = newWeight > 0 ? "\(Int(newWeight))" : ""
        updateSet(weight: newWeight, reps: set.reps)
    }
    
    private func incrementReps() {
        let currentReps = Int(repsText) ?? set.reps
        let newReps = currentReps + 1
        repsText = "\(newReps)"
        updateSet(weight: set.weight, reps: newReps)
    }
    
    private func decrementReps() {
        let currentReps = Int(repsText) ?? set.reps
        let newReps = max(0, currentReps - 1)
        repsText = newReps > 0 ? "\(newReps)" : ""
        updateSet(weight: set.weight, reps: newReps)
    }
    
    private func updateWeight(_ text: String) {
        let weight = Double(text) ?? 0
        updateSet(weight: weight, reps: set.reps)
    }
    
    private func updateReps(_ text: String) {
        let reps = Int(text) ?? 0
        updateSet(weight: set.weight, reps: reps)
    }
    
    private func updateSet(weight: Double, reps: Int) {
        var updatedSet = set
        updatedSet.weight = weight
        updatedSet.reps = reps
        onUpdate(updatedSet)
    }
}

// MARK: - Add Exercise Sheet

struct AddExerciseSheet: View {
    @Environment(\.dismiss) var dismiss
    let onAdd: (String) -> Void
    
    @State private var exerciseName = ""
    @State private var searchText = ""
    
    // Common exercises list
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
                    // Search bar
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
                    
                    // Exercise list
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
                            
                            // Custom exercise option
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
    WorkoutLoggingView(session: DummyData.activeWorkout)
}
