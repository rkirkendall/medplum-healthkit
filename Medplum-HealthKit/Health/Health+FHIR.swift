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
                let obs = try fhirFactory?.observation(from: sample)
                obs?.status = .final
                let serviceReqRef = Reference()
                serviceReqRef.reference = "ServiceRequest/2daad37c-fec8-4467-8424-d6cd18cae436"
                obs?.basedOn = [serviceReqRef]
                let ptRef = Reference()
                ptRef.reference = "Patient/56799d75-b773-4f83-b4ac-ffc47fe982c8"                                  
                obs?.subject = ptRef
                // obs?.subject INSERT PT ID HERE
                return obs
            }
            catch {
                print("Building an observation failed: \(sample)")
                return nil
            }
        }
        
        return observations
        
    }
}
