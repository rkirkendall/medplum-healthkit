# medplum-healthkit
A reference implementation for connecting iOS HealthKit data to Medplum for a simple patient monitoring use case.

This example queries HealthKit to extract data samples, 
convert them into FHIR observation objects, and send post them to a Medplum instance. Features include:

1. App [authorization for HealthKit](https://github.com/rkirkendall/medplum-healthkit/blob/main/Medplum-HealthKit/Health/Health.swift) read-only access
2. Use of [Observer queries](https://github.com/rkirkendall/medplum-healthkit/blob/main/Medplum-HealthKit/Health/Health%2BQueries.swift) for passive background monitoring of newly added / removed samples
3. Use of [Anchor queries](https://github.com/rkirkendall/medplum-healthkit/blob/main/Medplum-HealthKit/Health/Health%2BAnchor.swift) for paginated sample extraction 
4. Conversion of HealthKit samples to FHIR Observation objects via Microsoft's [HealthKit to FHIR project](https://github.com/microsoft/healthkit-to-fhir)
5. Use of Medplum's RESTful API to [POST observations](https://github.com/rkirkendall/medplum-healthkit/blob/main/Medplum-HealthKit/Health/Medplum.swift) to patient records
