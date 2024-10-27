//
//  HealthStore.swift
//  PowerHealth
//
//  Created by Pierre Untas on 27/10/2024.
//

import HealthKit

class HealthStore {
    private var healthStore = HKHealthStore()

    func requestAuthorization(completion: @escaping (Bool) -> Void) {
        let stepCountType = HKObjectType.quantityType(forIdentifier: .stepCount)!
        let calorieCountType = HKObjectType.quantityType(forIdentifier: .activeEnergyBurned)!
        let distanceType = HKObjectType.quantityType(forIdentifier: .distanceWalkingRunning)!
        
        let typesToShare: Set = [calorieCountType, distanceType]
        let typesToRead: Set = [stepCountType, calorieCountType, distanceType]

        healthStore.requestAuthorization(toShare: typesToShare, read: typesToRead) { success, error in
            completion(success)
        }
    }

    func fetchSteps(for date: Date, completion: @escaping (Double) -> Void) {
        guard let type = HKObjectType.quantityType(forIdentifier: .stepCount) else {
            completion(0)
            return
        }
        
        let startOfDay = Calendar.current.startOfDay(for: date)
        let endOfDay = Calendar.current.date(byAdding: .day, value: 1, to: startOfDay)!
        let predicate = HKQuery.predicateForSamples(withStart: startOfDay, end: endOfDay, options: .strictEndDate)

        let query = HKSampleQuery(sampleType: type, predicate: predicate, limit: HKObjectQueryNoLimit, sortDescriptors: nil) { (_, results, _) in
            let totalSteps = results?.compactMap { ($0 as? HKQuantitySample)?.quantity.doubleValue(for: HKUnit.count()) }.reduce(0, +) ?? 0
            completion(totalSteps)
        }

        healthStore.execute(query)
    }

    func fetchAverageStepsSinceBeginning(completion: @escaping (Double) -> Void) {
        guard let type = HKObjectType.quantityType(forIdentifier: .stepCount) else {
            completion(0)
            return
        }

        let predicate = HKQuery.predicateForSamples(withStart: nil, end: nil, options: .strictEndDate)

        let query = HKSampleQuery(sampleType: type, predicate: predicate, limit: HKObjectQueryNoLimit, sortDescriptors: nil) { (_, results, _) in
            let totalSteps = results?.compactMap { ($0 as? HKQuantitySample)?.quantity.doubleValue(for: HKUnit.count()) }.reduce(0, +) ?? 0
            let averageSteps = totalSteps / Double(results?.count ?? 1)
            completion(averageSteps)
        }

        healthStore.execute(query)
    }

    func fetchCalories(for date: Date, completion: @escaping (Double) -> Void) {
        guard let type = HKObjectType.quantityType(forIdentifier: .activeEnergyBurned) else {
            completion(0)
            return
        }
        
        let startOfDay = Calendar.current.startOfDay(for: date)
        let endOfDay = Calendar.current.date(byAdding: .day, value: 1, to: startOfDay)!
        let predicate = HKQuery.predicateForSamples(withStart: startOfDay, end: endOfDay, options: .strictEndDate)

        let query = HKSampleQuery(sampleType: type, predicate: predicate, limit: HKObjectQueryNoLimit, sortDescriptors: nil) { (_, results, _) in
            let totalCalories = results?.compactMap { ($0 as? HKQuantitySample)?.quantity.doubleValue(for: HKUnit.kilocalorie()) }.reduce(0, +) ?? 0
            completion(totalCalories)
        }

        healthStore.execute(query)
    }

    func fetchDistance(for date: Date, completion: @escaping (Double) -> Void) {
        guard let type = HKObjectType.quantityType(forIdentifier: .distanceWalkingRunning) else {
            completion(0)
            return
        }
        
        let startOfDay = Calendar.current.startOfDay(for: date)
        let endOfDay = Calendar.current.date(byAdding: .day, value: 1, to: startOfDay)!
        let predicate = HKQuery.predicateForSamples(withStart: startOfDay, end: endOfDay, options: .strictEndDate)

        let query = HKSampleQuery(sampleType: type, predicate: predicate, limit: HKObjectQueryNoLimit, sortDescriptors: nil) { (_, results, _) in
            let totalDistance = results?.compactMap { ($0 as? HKQuantitySample)?.quantity.doubleValue(for: HKUnit.meter()) }.reduce(0, +) ?? 0
            completion(totalDistance)
        }

        healthStore.execute(query)
    }
}
