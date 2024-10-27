//
//  ContentView.swift
//  PowerHealth
//
//  Created by Pierre Untas on 26/10/2024.
//

import SwiftUI

struct ContentView: View {
    @State private var stepCountToday: Double = 0
    @State private var stepCountYesterday: Double = 0
    @State private var averageStepCount: Double = 0
    @State private var caloriesBurnedToday: Double = 0
    @State private var distanceWalkedToday: Double = 0
    private var healthStore = HealthStore()
    
    var body: some View {
        VStack {
            Text("Terminal d'Activité")
                .font(.system(size: 36, weight: .bold, design: .monospaced))
                .foregroundColor(.green)
                .padding(.top, 40)
            
            Spacer()
            
            TerminalSection(title: "Pas Aujourd'hui:", value: stepCountToday)
            TerminalSection(title: "Pas Hier:", value: stepCountYesterday)
            TerminalSection(title: "Moyenne (Depuis le Début):", value: averageStepCount)
            TerminalSection(title: "Calories Brûlées Aujourd'hui:", value: caloriesBurnedToday)
            TerminalSection(title: "Distance Parcourue Aujourd'hui (m):", value: distanceWalkedToday)
            
            Spacer()
        }
        .padding()
        .background(Color.black.edgesIgnoringSafeArea(.all))
        .onAppear {
            healthStore.requestAuthorization { success in
                if success {
                    healthStore.fetchSteps(for: Date()) { steps in
                        DispatchQueue.main.async {
                            stepCountToday = steps
                        }
                    }
                    
                    if let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: Date()) {
                        healthStore.fetchSteps(for: yesterday) { steps in
                            DispatchQueue.main.async {
                                stepCountYesterday = steps
                            }
                        }
                    }
                    
                    healthStore.fetchAverageStepsSinceBeginning { averageSteps in
                        DispatchQueue.main.async {
                            averageStepCount = averageSteps
                        }
                    }
                    
                    // Récupérer les calories brûlées
                    healthStore.fetchCalories(for: Date()) { calories in
                        DispatchQueue.main.async {
                            caloriesBurnedToday = calories
                        }
                    }
                    
                    // Récupérer la distance parcourue
                    healthStore.fetchDistance(for: Date()) { distance in
                        DispatchQueue.main.async {
                            distanceWalkedToday = distance
                        }
                    }
                }
            }
        }
    }
}

struct TerminalSection: View {
    var title: String
    var value: Double

    var body: some View {
        HStack {
            Text(title)
                .font(.system(size: 24, weight: .regular, design: .monospaced))
                .foregroundColor(.green)
            Spacer()
            Text("\(Int(value))")
                .font(.system(size: 24, weight: .regular, design: .monospaced))
                .foregroundColor(.green)
        }
        .padding()
        .background(Color.black.opacity(0.8))
        .cornerRadius(5)
        .overlay(
            RoundedRectangle(cornerRadius: 5)
                .stroke(Color.green, lineWidth: 1)
        )
        .padding(.vertical, 5)
    }
}
