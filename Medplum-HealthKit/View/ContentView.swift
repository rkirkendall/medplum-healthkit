//
//  ContentView.swift
//  Medplum-HealthKit
//
//  Created by Ricky Kirkendall on 10/26/22.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        VStack {
            Text("Hello, HealthKit")
                .padding()
            Button("Authorize") {
                Health.requestAuthorization()
            }
            Spacer()
            Button("Reset") {
                Health.resetMonitoring()
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
