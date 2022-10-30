//
//  Health.swift
//  Medplum-HealthKit
//
//  Created by Ricky Kirkendall on 10/26/22.
//

import Foundation
import HealthKit

struct Health {
    
    static let kAnchorQueryResultLimit: Int = 200
    static let kAnchorStoreKey = "lastAnchor"    
    
    static let healthStore = HKHealthStore.init()
    static let allTypes = Set([HKQuantityType(.stepCount)])    
    
    static func requestAuthorization() {
        if !HKHealthStore.isHealthDataAvailable() { return }
        healthStore.requestAuthorization(toShare: nil, read: allTypes) { success, error in
            if !success && error != nil {
                print(error!.localizedDescription)
            } else {
                print("Seems to have worked")
                startMonitoring()
            }
        }
    }
    
}
