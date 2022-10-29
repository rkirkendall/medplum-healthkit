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
                        // TODO: Re-run the anchor query if it finds stuff
                        // to account for when there is more samples than allowed
                        // from the query max return
                        
                        for s in newSamples {
                            print(s.description)
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
                
        let observerQueryDescriptors = allTypes.map { type in
            HKQueryDescriptor(sampleType: type, predicate: nil)
        }
        
        let observerQuery = HKObserverQuery(queryDescriptors: observerQueryDescriptors)
        { query, updatedSampleTypes, completionHandler, error in
            
            if let error = error {
                print("Observer query problem: \(error.localizedDescription)")
            }
            
            if let types = updatedSampleTypes {
                let anchorQueryDescriptors = types.map { type in
                    HKQueryDescriptor(sampleType: type, predicate: nil)
                }
                
                executeAnchorQuery(queryDescriptors: anchorQueryDescriptors, completionHandler: completionHandler)
            }
        }
        
        healthStore.execute(observerQuery)
        
        for type in allTypes {
            healthStore.enableBackgroundDelivery(for: type, frequency: .immediate) { success, error in
                if !success {
                    print("Problem enabling background delivery for \(type.description):\n\(error?.localizedDescription ?? "iunno")")
                }
            }
        }
    }
    
    // Observer query: Long running. Has background delivery. Doesn't have list of items
    // Anchored object query: Long running. Gives list of items. No background delivery.
    
    static func loadAnchor() -> HKQueryAnchor? {
        let encoded = UserDefaults.standard.data(forKey: kAnchorStoreKey)
                
        guard let unwrappedEncoded = encoded else { return nil }
        
        guard let anchor = try? NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(unwrappedEncoded as Data) as? HKQueryAnchor
        else {
            print("Problem fetching anchor")
            return nil
        }
        return anchor
    }
    
    static func saveAnchor(_ anchor: HKQueryAnchor) {
        do {
            let encoded = try NSKeyedArchiver.archivedData(withRootObject: anchor, requiringSecureCoding: false)
            print("Attempting to save anchor: \(encoded.description)")
            UserDefaults.standard.set(encoded, forKey: kAnchorStoreKey)
        } catch {
            print("Problem saving anchor")
        }
    }
    
}
