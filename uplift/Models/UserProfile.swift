//
//  UserProfile.swift
//  uplift
//
//  Created by Ruitao Chen on 12/3/25.
//

import Foundation

struct UserProfile: Codable {
    var id: UUID
    var name: String
    var email: String?
    var createdDate: Date
    var preferences: UserPreferences
    
    init(
        id: UUID = UUID(),
        name: String,
        email: String? = nil,
        createdDate: Date = Date(),
        preferences: UserPreferences = UserPreferences()
    ) {
        self.id = id
        self.name = name
        self.email = email
        self.createdDate = createdDate
        self.preferences = preferences
    }
}

struct UserPreferences: Codable {
    var weightUnit: WeightUnit
    var defaultRestTime: Int // seconds
    var showWarmupSets: Bool
    var autoStartTimer: Bool
    
    init(
        weightUnit: WeightUnit = .pounds,
        defaultRestTime: Int = 90,
        showWarmupSets: Bool = false,
        autoStartTimer: Bool = true
    ) {
        self.weightUnit = weightUnit
        self.defaultRestTime = defaultRestTime
        self.showWarmupSets = showWarmupSets
        self.autoStartTimer = autoStartTimer
    }
}

enum WeightUnit: String, Codable, CaseIterable {
    case pounds = "lbs"
    case kilograms = "kg"
    
    var displayName: String {
        switch self {
        case .pounds: return "Pounds"
        case .kilograms: return "Kilograms"
        }
    }
}
