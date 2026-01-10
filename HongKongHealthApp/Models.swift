//
//  MealEntry.swift
//  HongKongHealthApp
//
//  Created by Ye on 16/1/2026.
//


import Foundation

struct MealEntry: Identifiable, Codable {
    var id = UUID()
    var name: String
    var calories: Int
    var saltLevel: String
    var date: Date = Date()
    var imageData: Data?
}

struct HikeEntry: Identifiable, Codable {
    var id = UUID()
    var date: Date = Date()
    var distance: Double
    var calories: Int
    var duration: TimeInterval
}

struct MoodEntry: Identifiable, Codable {
    var id = UUID()
    var mood: Int
    var stress: Int
    var note: String
    var date: Date = Date()
}