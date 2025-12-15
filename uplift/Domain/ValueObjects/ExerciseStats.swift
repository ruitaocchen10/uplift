//
//  ExerciseStats.swift
//  uplift
//
//  Created by Ruitao Chen on 12/15/25.
//

import Foundation

struct ExerciseStats: Identifiable {
       let id = UUID()
       let exerciseName: String
       let personalBest: PersonalBest
       let totalWorkouts: Int
       let lastPerformed: Date?
       let maxWeightHistory: [DataPoint]
       let volumeHistory: [DataPoint]
   }
