//
//  Medplum_HealthKitApp.swift
//  Medplum-HealthKit
//
//  Created by Ricky Kirkendall on 10/26/22.
//

import SwiftUI

@main
struct Medplum_HealthKitApp: App {
    
    init() {
        Health.startMonitoring()
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
