//
//  Health+FHIR.swift
//  Medplum-HealthKit
//
//  Created by Ricky Kirkendall on 10/30/22.
//

import HealthKit
import HealthKitToFhir
import FHIR

extension Health {
    //FHIR
    static var fhirFactory: ObservationFactory? {
        do {
            return try ObservationFactory()
        } catch {
            print("Problem initializing the Observation Factory")
            return nil
        }
    }
    
    static func buildFHIRFromSamples(_ samples: [HKObject]) -> [Observation] {
        
        let observations: [Observation] = samples.compactMap { sample in
            do {
                return try fhirFactory?.observation(from: sample)
            }
            catch {
                print("Building an observation failed: \(sample)")
                return nil
            }
        }
        
        return observations
        
    }
}
