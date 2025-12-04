//
//  DummyData.swift
//  uplift
//
//  Created by Ruitao Chen on 12/4/25.
//

import Foundation

struct DummyData {
    
    // MARK: - Sample Templates
    
    static let sampleTemplates: [WorkoutTemplate] = [
        WorkoutTemplate(
            name: "Hypertrophy Push Workout",
            exercises: [
                TemplateExercise(name: "Bench Press", targetSets: 3, targetRepsMin: 12, targetRepsMax: 15),
                TemplateExercise(name: "Overhead Press", targetSets: 3, targetRepsMin: 10, targetRepsMax: 12),
                TemplateExercise(name: "Incline Dumbbell Press", targetSets: 3, targetRepsMin: 12, targetRepsMax: 15),
                TemplateExercise(name: "Tricep Pushdown", targetSets: 3, targetRepsMin: 12, targetRepsMax: 15)
            ]
        ),
        WorkoutTemplate(
            name: "Pull Day",
            exercises: [
                TemplateExercise(name: "Pull-ups", targetSets: 4, targetRepsMin: 8, targetRepsMax: 10),
                TemplateExercise(name: "Barbell Row", targetSets: 3, targetRepsMin: 10, targetRepsMax: 12),
                TemplateExercise(name: "Lat Pulldown", targetSets: 3, targetRepsMin: 12, targetRepsMax: 15),
                TemplateExercise(name: "Face Pulls", targetSets: 3, targetRepsMin: 15, targetRepsMax: 20)
            ]
        ),
        WorkoutTemplate(
            name: "Leg Day",
            exercises: [
                TemplateExercise(name: "Squats", targetSets: 4, targetRepsMin: 8, targetRepsMax: 10),
                TemplateExercise(name: "Romanian Deadlift", targetSets: 3, targetRepsMin: 10, targetRepsMax: 12),
                TemplateExercise(name: "Leg Press", targetSets: 3, targetRepsMin: 12, targetRepsMax: 15),
                TemplateExercise(name: "Leg Curls", targetSets: 3, targetRepsMin: 12, targetRepsMax: 15)
            ]
        ),
        WorkoutTemplate(
            name: "Shoulder-Focused Push Day",
            exercises: [
                TemplateExercise(name: "Overhead Barbell Press", targetSets: 3, targetRepsMin: 8, targetRepsMax: 8),
                TemplateExercise(name: "Bench Press", targetSets: 3, targetRepsMin: 12, targetRepsMax: 15),
                TemplateExercise(name: "Weighted Dips", targetSets: 3, targetRepsMin: 10, targetRepsMax: 12),
                TemplateExercise(name: "Tricep Pushdown", targetSets: 3, targetRepsMin: 12, targetRepsMax: 15)
            ]
        )
    ]
    
    // MARK: - Sample Workout Sessions
    
    static let completedWorkout: WorkoutSession = {
        WorkoutSession(
            templateName: "Hypertrophy Push Workout",
            date: Date(),
            exercises: [
                Exercise(name: "Bench Press", sets: [
                    WorkoutSet(weight: 135, reps: 15, isCompleted: true),
                    WorkoutSet(weight: 135, reps: 14, isCompleted: true),
                    WorkoutSet(weight: 135, reps: 12, isCompleted: true)
                ]),
                Exercise(name: "Overhead Press", sets: [
                    WorkoutSet(weight: 95, reps: 12, isCompleted: true),
                    WorkoutSet(weight: 95, reps: 11, isCompleted: true),
                    WorkoutSet(weight: 95, reps: 10, isCompleted: true)
                ]),
                Exercise(name: "Incline Dumbbell Press", sets: [
                    WorkoutSet(weight: 60, reps: 15, isCompleted: true),
                    WorkoutSet(weight: 60, reps: 14, isCompleted: true),
                    WorkoutSet(weight: 60, reps: 13, isCompleted: true)
                ])
            ],
            isCompleted: true
        )
    }()
    
    static let inProgressWorkout: WorkoutSession = {
        WorkoutSession(
            templateName: "Pull Day",
            date: Date(),
            exercises: [
                Exercise(name: "Pull-ups", sets: [
                    WorkoutSet(weight: 0, reps: 10, isCompleted: true),
                    WorkoutSet(weight: 0, reps: 9, isCompleted: true),
                    WorkoutSet(weight: 0, reps: 0, isCompleted: false),
                    WorkoutSet(weight: 0, reps: 0, isCompleted: false)
                ]),
                Exercise(name: "Barbell Row", sets: [
                    WorkoutSet(weight: 0, reps: 0, isCompleted: false),
                    WorkoutSet(weight: 0, reps: 0, isCompleted: false),
                    WorkoutSet(weight: 0, reps: 0, isCompleted: false)
                ])
            ],
            isCompleted: false
        )
    }()
    
    static let activeWorkout: WorkoutSession = {
        WorkoutSession(
            templateName: "Shoulder-Focused Push Day",
            date: Date(),
            exercises: [
                Exercise(name: "Overhead Barbell Press", sets: [
                    WorkoutSet(weight: 135, reps: 8, isCompleted: true),
                    WorkoutSet(weight: 135, reps: 7, isCompleted: true),
                    WorkoutSet(weight: 145, reps: 5, isCompleted: true)
                ], isExpanded: true),
                Exercise(name: "Bench Press", sets: [
                    WorkoutSet(weight: 0, reps: 0, isCompleted: false),
                    WorkoutSet(weight: 0, reps: 0, isCompleted: false),
                    WorkoutSet(weight: 0, reps: 0, isCompleted: false)
                ], isExpanded: false),
                Exercise(name: "Weighted Dips", sets: [
                    WorkoutSet(weight: 0, reps: 0, isCompleted: false),
                    WorkoutSet(weight: 0, reps: 0, isCompleted: false),
                    WorkoutSet(weight: 0, reps: 0, isCompleted: false)
                ], isExpanded: false),
                Exercise(name: "Tricep Pushdown", sets: [
                    WorkoutSet(weight: 0, reps: 0, isCompleted: false),
                    WorkoutSet(weight: 0, reps: 0, isCompleted: false),
                    WorkoutSet(weight: 0, reps: 0, isCompleted: false)
                ], isExpanded: false)
            ],
            isCompleted: false
        )
    }()
    
    // MARK: - Sample Dates with Workouts (for calendar heatmap)
    
    static let datesWithWorkouts: Set<Date> = {
        let calendar = Calendar.current
        let today = Date()
        
        return Set([
            today,
            calendar.date(byAdding: .day, value: -1, to: today)!,
            calendar.date(byAdding: .day, value: -3, to: today)!,
            calendar.date(byAdding: .day, value: -4, to: today)!,
            calendar.date(byAdding: .day, value: -6, to: today)!,
            calendar.date(byAdding: .day, value: -8, to: today)!,
            calendar.date(byAdding: .day, value: -10, to: today)!
        ])
    }()
    
    // MARK: - Multiple Workouts (for testing list views)
    
    static let sampleWorkouts: [WorkoutSession] = [
        completedWorkout,
        WorkoutSession(
            templateName: "Pull Day",
            date: Calendar.current.date(byAdding: .day, value: -1, to: Date())!,
            exercises: [
                Exercise(name: "Pull-ups", sets: Array(repeating: WorkoutSet(weight: 0, reps: 10, isCompleted: true), count: 4)),
                Exercise(name: "Barbell Row", sets: Array(repeating: WorkoutSet(weight: 135, reps: 10, isCompleted: true), count: 3))
            ],
            isCompleted: true
        ),
        WorkoutSession(
            templateName: "Leg Day",
            date: Calendar.current.date(byAdding: .day, value: -3, to: Date())!,
            exercises: [
                Exercise(name: "Squats", sets: Array(repeating: WorkoutSet(weight: 225, reps: 8, isCompleted: true), count: 4)),
                Exercise(name: "Romanian Deadlift", sets: Array(repeating: WorkoutSet(weight: 185, reps: 10, isCompleted: true), count: 3))
            ],
            isCompleted: true
        )
    ]
}
