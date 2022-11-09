//
//  Medplum.swift
//  Medplum-HealthKit
//
//  Created by Ricky Kirkendall on 10/31/22.
//

import FHIR
import Foundation
import SwiftUI

struct Medplum {
    let urlSession: URLSession
    let token = ""
    
    init() {
        let config = URLSessionConfiguration.default
        config.httpAdditionalHeaders = ["Authorization": Medplum.Token,
                                        "Content-Type": "application/json"]
        urlSession = URLSession(configuration: config)
    }
    
    struct MedplumAPI {
        static let scheme = "http"
        static let host = "127.0.0.1"
        static let port = 8103
    }
    
    func createObservation(_ observation: Observation) {
        let path = "/fhir/R4" + "/Observation"
        var components = URLComponents()
        components.scheme = MedplumAPI.scheme
        components.host = MedplumAPI.host
        components.port = MedplumAPI.port
        components.path = path
        
        print(components.description)
        let url = components.url
        
        var request = URLRequest(url: url!)
        request.httpMethod = "POST"
                
        let jsonData = try! JSONSerialization.data(withJSONObject: observation.asJSON(), options: .prettyPrinted)
//        print(String(decoding: js, as: UTF8.self))
        
        request.httpBody = jsonData
                
        let task = urlSession.dataTask(with: request) { body, response, error in
            if error != nil {
                print(error.debugDescription)
            } else {
//                print(response.debugDescription)
            }
            
            if body != nil {
                print("Response: \(String(decoding: body!, as: UTF8.self))")
            }
            
            
        }
        task.resume()
    }
    
}
