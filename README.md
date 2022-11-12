# medplum-healthkit
A reference implementation for connecting iOS HealthKit data to [Medplum Headless EHR](https://github.com/medplum/medplum) for a simple patient monitoring use case.

This example queries HealthKit to extract data samples, 
convert them into FHIR observation objects, and send post them to a Medplum instance. Features include:

1. App [authorization for HealthKit](https://github.com/rkirkendall/medplum-healthkit/blob/main/Medplum-HealthKit/Health/Health.swift) read-only access
2. Use of [Observer queries](https://github.com/rkirkendall/medplum-healthkit/blob/main/Medplum-HealthKit/Health/Health%2BQueries.swift) for passive background monitoring of newly added / removed samples
3. Use of [Anchor queries](https://github.com/rkirkendall/medplum-healthkit/blob/main/Medplum-HealthKit/Health/Health%2BAnchor.swift) for paginated sample extraction 
4. Conversion of HealthKit samples to FHIR Observation objects via Microsoft's [HealthKit to FHIR project](https://github.com/microsoft/healthkit-to-fhir)
5. Use of Medplum's RESTful API to [POST observations](https://github.com/rkirkendall/medplum-healthkit/blob/main/Medplum-HealthKit/Health/Medplum.swift) to patient records

## Demo

[![Demo video](https://cdn.loom.com/sessions/thumbnails/e7e029754d9e46719c753ebe2bf6f062-with-play.gif)](https://www.loom.com/share/e7e029754d9e46719c753ebe2bf6f062)

## Set up

### Run in Xcode

Open the .xcodeproj file in Xcode. Make sure you have an Apple Developer License to sign the project with before you try running on a device / simulator

By default, the medplum endpoints are pointed at localhost. You can modify that in `Medplum.swift`. For simple authentication with Medplum, this project uses a hard-coded Bearer token that you will need to provide. To do this, extend the Medplum struct and add a static `Token` property

```swift
extension Medplum {
    static let Token = "Bearer ey..."
}
```

Once the app is running, tap the Authorize button to trigger the HealthKit permission UI. Toggle "Steps" to on and tap Allow.

### Working with Sample data

If you don't have a paid developer account you can try the project out on the simulator. Run the app on the simulator, tap the home button and open the Apple Health app. To simulate a total count of steps that iPhone or Apple Watch might capture for a day of activity, tap on "Steps" and then "Add data".

<img src="https://user-images.githubusercontent.com/1122859/201167269-cefc4768-97c5-4b43-ae04-f94dc028e386.png" width=20% height=20%>

Open the Medplum-HealthKit app once again and check the logs in the Xcode. If you've authorized the app and added a valid bearer token, you should see POST responses from the new samples getting sent to Medplum. Note: On device, these sample POST requests would happen as part of background delivery if the app is backgroudned (within reasonable limitations permitted by iOS). Using the simulator, however, we must reopen the app in the foreground for the queries to take action.

### Seeing data in Medplum

Using the default Medplum web app, navigate to http://localhost:3000/Observation to see a list of all Observations. If you want to modify the patient associated with the observation, you can do that by updating the [patient reference here](https://github.com/rkirkendall/medplum-healthkit/blob/main/Medplum-HealthKit/Health/Health%2BFHIR.swift).
