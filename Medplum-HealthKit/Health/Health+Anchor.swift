//
//  Health+Anchor.swift
//  Medplum-HealthKit
//
//  Created by Ricky Kirkendall on 10/30/22.
//

import HealthKit

extension Health {
    
    static func clearAnchor() {
        UserDefaults.standard.removeObject(forKey: kAnchorStoreKey)
    }
    
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
