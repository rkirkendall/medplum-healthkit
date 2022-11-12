//
//  Health+Queries.swift
//  Medplum-HealthKit
//
//  Created by Ricky Kirkendall on 10/30/22.
//

import Foundation
import HealthKit

extension Health {
    
    static var observerQuery: HKObserverQuery {
        let observerQueryDescriptors = allTypes.map { type in
            HKQueryDescriptor(sampleType: type, predicate: nil)
        }
        
        return HKObserverQuery(queryDescriptors: observerQueryDescriptors)
        { query, updatedSampleTypes, completionHandler, error in
            
            if let error = error {
                print("Observer query problem: \(error.localizedDescription)")
            }
            
            if let types = updatedSampleTypes {
                let anchorQueryDescriptors = types.map { type in
                    HKQueryDescriptor(sampleType: type, predicate: nil)
                }
                
                if anchorQueryDescriptors.count > 0 {
                    executeAnchorQuery(queryDescriptors: anchorQueryDescriptors, completionHandler: completionHandler)
                }
            }
        }
    }
    
    static func resetMonitoring() {
        clearAnchor()
        healthStore.stop(observerQuery)
        startMonitoring()
    }
    
    static func startMonitoring() {
        if !HKHealthStore.isHealthDataAvailable() { return }
        healthStore.getRequestStatusForAuthorization(toShare: Set(), read: allTypes) { authStatus, error in
            
            if let error = error {
                print("Problem getting current Auth status: \(error.localizedDescription)")
            }
            switch(authStatus) {
            case .shouldRequest, .unknown:
                print("Hold your horses")
                return
            case .unnecessary:
                print("Ready to rock. Executing queries.")
                executeObserverQuery()
            @unknown default:
                return
            }
            
        }
    }
    
    // Observer query: Long running. Has background delivery. Doesn't have list of items
    // Anchored object query: Long running. Gives list of items. No background delivery.
    
    private static func executeAnchorQuery(queryDescriptors:[HKQueryDescriptor], completionHandler: @escaping HKObserverQueryCompletionHandler) {
        let lastAnchor = loadAnchor()
        print("Running anchor query again")
        let anchorQuery = HKAnchoredObjectQuery(
            queryDescriptors: queryDescriptors,
            anchor: lastAnchor,
            limit: kAnchorQueryResultLimit) {
            anchorQuery, newSamples, deletedSamples, newAnchor, error in
                if let error = error {
                    print("Anchor query problem: \(error.localizedDescription)")
                }
                
                DispatchQueue.main.async {
                    // TODO: only update anchor once samples have been successfully uploaded
                    if let newAnchor = newAnchor {
                        saveAnchor(newAnchor)
                    }
                    
                    var shouldQueryAgain = false
                    
                    // Process new and deleted samples
                    if let newSamples = newSamples {
                        print("New samples: ")
                        
                        let fhirSamples = buildFHIRFromSamples(newSamples)
                        for s in fhirSamples {
                            medplum.createObservation(s)
                        }
                        
                        
                        if newSamples.count > 0 {
                            shouldQueryAgain = true
                        }
                    }
                    
                    if let deletedSamples = deletedSamples {
                        print("Deleted samples: ")
                        for s in deletedSamples {
                            print(s.description)
                        }
                        if deletedSamples.count > 0 {
                            shouldQueryAgain = true
                        }
                    }
                    
                    if shouldQueryAgain {
                        executeAnchorQuery(queryDescriptors: queryDescriptors, completionHandler: completionHandler)
                    }else {
                        // Call observer completion handler
                        completionHandler()
                    }
                }
        }
        
        healthStore.execute(anchorQuery)
    }
    
    private static func executeObserverQuery() {
        healthStore.execute(observerQuery)
        
        for type in allTypes {
            healthStore.enableBackgroundDelivery(for: type, frequency: .immediate) { success, error in
                if !success {
                    print("Problem enabling background delivery for \(type.description):\n\(error?.localizedDescription ?? "iunno")")
                }
            }
        }
    }
}
