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
    
    // MARK: - Sample Workout Sessions with Month of History
    
    static let sampleWorkouts: [WorkoutSession] = {
        let calendar = Calendar.current
        let today = Date()
        var workouts: [WorkoutSession] = []
        
        // Generate workouts for the past 30 days
        // Pattern: 3-4 workouts per week (Push, Pull, Legs rotation)
        
        let workoutDays = [1, 3, 5, 8, 10, 12, 15, 17, 19, 22, 24, 26, 29] // Days ago
        
        for (index, daysAgo) in workoutDays.enumerated() {
            guard let workoutDate = calendar.date(byAdding: .day, value: -daysAgo, to: today) else { continue }
            
            // Rotate through workout types
            let workoutType = index % 3
            
            switch workoutType {
            case 0: // Push Day
                workouts.append(createPushWorkout(date: workoutDate, progressionLevel: index))
            case 1: // Pull Day
                workouts.append(createPullWorkout(date: workoutDate, progressionLevel: index))
            case 2: // Leg Day
                workouts.append(createLegWorkout(date: workoutDate, progressionLevel: index))
            default:
                break
            }
        }
        
        // Add one in-progress workout for today
        workouts.append(inProgressWorkout)
        
        return workouts.sorted { $0.date > $1.date }
    }()
    
    // MARK: - Workout Builders with Progression
    
    private static func createPushWorkout(date: Date, progressionLevel: Int) -> WorkoutSession {
        // Simulate progressive overload
        let benchBase = 135.0 + Double(progressionLevel * 5) // Start at 135, add 5 lbs each session
        let ohpBase = 95.0 + Double(progressionLevel * 3) // Start at 95, add 3 lbs each session
        let inclineBase = 60.0 + Double(progressionLevel * 3)
        
        return WorkoutSession(
            templateName: "Push Day",
            date: date,
            exercises: [
                Exercise(name: "Bench Press", sets: [
                    WorkoutSet(weight: benchBase, reps: 12, isCompleted: true),
                    WorkoutSet(weight: benchBase, reps: 11, isCompleted: true),
                    WorkoutSet(weight: benchBase, reps: 10, isCompleted: true)
                ]),
                Exercise(name: "Overhead Press", sets: [
                    WorkoutSet(weight: ohpBase, reps: 10, isCompleted: true),
                    WorkoutSet(weight: ohpBase, reps: 9, isCompleted: true),
                    WorkoutSet(weight: ohpBase, reps: 8, isCompleted: true)
                ]),
                Exercise(name: "Incline Dumbbell Press", sets: [
                    WorkoutSet(weight: inclineBase, reps: 12, isCompleted: true),
                    WorkoutSet(weight: inclineBase, reps: 12, isCompleted: true),
                    WorkoutSet(weight: inclineBase, reps: 11, isCompleted: true)
                ])
            ],
            isCompleted: true
        )
    }
    
    private static func createPullWorkout(date: Date, progressionLevel: Int) -> WorkoutSession {
        let pullUpBase = 0.0 // Bodyweight
        let rowBase = 135.0 + Double(progressionLevel * 5)
        let latBase = 100.0 + Double(progressionLevel * 5)
        
        return WorkoutSession(
            templateName: "Pull Day",
            date: date,
            exercises: [
                Exercise(name: "Pull-ups", sets: [
                    WorkoutSet(weight: pullUpBase, reps: 10, isCompleted: true),
                    WorkoutSet(weight: pullUpBase, reps: 9, isCompleted: true),
                    WorkoutSet(weight: pullUpBase, reps: 8, isCompleted: true),
                    WorkoutSet(weight: pullUpBase, reps: 7, isCompleted: true)
                ]),
                Exercise(name: "Barbell Row", sets: [
                    WorkoutSet(weight: rowBase, reps: 10, isCompleted: true),
                    WorkoutSet(weight: rowBase, reps: 10, isCompleted: true),
                    WorkoutSet(weight: rowBase, reps: 9, isCompleted: true)
                ]),
                Exercise(name: "Lat Pulldown", sets: [
                    WorkoutSet(weight: latBase, reps: 12, isCompleted: true),
                    WorkoutSet(weight: latBase, reps: 12, isCompleted: true),
                    WorkoutSet(weight: latBase, reps: 11, isCompleted: true)
                ])
            ],
            isCompleted: true
        )
    }
    
    private static func createLegWorkout(date: Date, progressionLevel: Int) -> WorkoutSession {
        let squatBase = 185.0 + Double(progressionLevel * 10)
        let rdlBase = 135.0 + Double(progressionLevel * 5)
        let legPressBase = 270.0 + Double(progressionLevel * 20)
        
        return WorkoutSession(
            templateName: "Leg Day",
            date: date,
            exercises: [
                Exercise(name: "Squats", sets: [
                    WorkoutSet(weight: squatBase, reps: 8, isCompleted: true),
                    WorkoutSet(weight: squatBase, reps: 8, isCompleted: true),
                    WorkoutSet(weight: squatBase, reps: 7, isCompleted: true),
                    WorkoutSet(weight: squatBase, reps: 6, isCompleted: true)
                ]),
                Exercise(name: "Romanian Deadlift", sets: [
                    WorkoutSet(weight: rdlBase, reps: 10, isCompleted: true),
                    WorkoutSet(weight: rdlBase, reps: 10, isCompleted: true),
                    WorkoutSet(weight: rdlBase, reps: 9, isCompleted: true)
                ]),
                Exercise(name: "Leg Press", sets: [
                    WorkoutSet(weight: legPressBase, reps: 12, isCompleted: true),
                    WorkoutSet(weight: legPressBase, reps: 12, isCompleted: true),
                    WorkoutSet(weight: legPressBase, reps: 11, isCompleted: true)
                ])
            ],
            isCompleted: true
        )
    }
    
    // MARK: - In-Progress Workout (for testing)
    
    private static var inProgressWorkout: WorkoutSession {
        WorkoutSession(
            templateName: "Push Day",
            date: Date(),
            exercises: [
                Exercise(name: "Bench Press", sets: [
                    WorkoutSet(weight: 135, reps: 12, isCompleted: true),
                    WorkoutSet(weight: 135, reps: 11, isCompleted: true),
                    WorkoutSet(weight: 145, reps: 0, isCompleted: false)
                ], isExpanded: true),
                Exercise(name: "Overhead Press", sets: [
                    WorkoutSet(weight: 0, reps: 0, isCompleted: false),
                    WorkoutSet(weight: 0, reps: 0, isCompleted: false),
                    WorkoutSet(weight: 0, reps: 0, isCompleted: false)
                ], isExpanded: false)
            ],
            isCompleted: false
        )
    }
    
    // MARK: - Active Workout (for WorkoutLoggingView testing)
    
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
        return Set(sampleWorkouts.filter { $0.isCompleted }.map { workout in
            calendar.startOfDay(for: workout.date)
        })
    }()
}
