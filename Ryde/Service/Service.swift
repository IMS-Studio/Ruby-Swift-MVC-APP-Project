//
//  Service.swift
//  Ryde
//
//  Created by KEVIN ROMANO on 5/10/20.
//  Copyright © 2020 KEVIN ROMANO. All rights reserved.
//

import Firebase
import CoreLocation
import GeoFire

let DB_REF = Database.database().reference()
let REF_USERS = DB_REF.child("users")
let REF_DRIVER_LOCATIONS = DB_REF.child("driver-locations")
let REF_TRIPS = DB_REF.child("trips")

struct Service {
    
    static let shared = Service()
    
    // fetches user data
    func fetchUserData(uid: String, completion: @escaping(User) -> Void) {
        REF_USERS.child(uid).observeSingleEvent(of: .value) { (DataSnapshot) in
            guard let dict = DataSnapshot.value as? [String: Any] else { return }
            let uid = DataSnapshot.key
            let user = User(uid: uid, dictionary: dict)
            print("location is: \(REF_DRIVER_LOCATIONS.child)")
            print("user is: \(REF_USERS.child)")
            completion(user)
        }
        
    }
    
    // returns all the drivers that are in the proximity of the user's location
    func fetchDrivers(location: CLLocation, completion: @escaping(User) -> Void) {
        let geofire = GeoFire(firebaseRef: REF_DRIVER_LOCATIONS)
        REF_DRIVER_LOCATIONS.observe(.value) { (snapshot) in
            geofire.query(at: location, withRadius: 50).observe(.keyEntered, with: { (uid, location) in
                self.fetchUserData(uid: uid) { (user) in
                    var driver = user
                    driver.location = location
                    completion(driver)
                }
            })
        }
    }
    
    func uploadTrip(_ pickupCoordinates: CLLocationCoordinate2D, _ destinationCoordinates: CLLocationCoordinate2D,
                    completion: @escaping(Error?, DatabaseReference) -> Void) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        let pickupArray = [pickupCoordinates.latitude, pickupCoordinates.longitude]
        let destinationArray = [destinationCoordinates.latitude, destinationCoordinates.longitude]
        
        let values = ["pickupCoordinates": pickupArray,
                      "destinationCoordinates": destinationArray,
                      "state": TripState.requested.rawValue] as [String : Any]
        
        REF_TRIPS.child(uid).updateChildValues(values, withCompletionBlock: completion)
    }
    
    /* listener function that checks whether a new item is added
     to the Trips reference */
    func observeTrips(completion: @escaping(Trip) -> Void) {
        REF_TRIPS.observe(.childAdded) { (snapshot) in
            guard let dictionary = snapshot.value as? [String: Any] else { return }
            let uid = snapshot.key
            let trip = Trip(passengerUid: uid, dictionary: dictionary)
            completion(trip)
        }
    }
    
    func observeUpdateTrips(completion: @escaping(Trip?) -> Void) {
        var time: Int = 0
        Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { timer in
            time += 1
            if time == 6 {
                timer.invalidate()
                print("Schedule: Time limit exceeded")
                completion(nil)
            }
            else {
                REF_TRIPS.observeSingleEvent(of: .childChanged) { (snapshot) in
                    timer.invalidate()
                    guard let dictionary = snapshot.value as? [String: Any] else { return }
                    let uid = snapshot.key
                    let trip = Trip(passengerUid: uid, dictionary: dictionary)
                    completion(trip)
                }
                REF_TRIPS.observeSingleEvent(of:.childRemoved) { (snapshot) in
                    timer.invalidate()
                    guard let dictionary = snapshot.value as? [String: Any] else { return }
                    let uid = snapshot.key
                    let trip = Trip(passengerUid: uid, dictionary: dictionary)
                    dictionary["state"] as? Int == 0 ? completion(trip) : nil
                }
            }
        }
    }
    
    func acceptTrips(uid: String, completion: @escaping() -> Void) {
        REF_TRIPS.child(uid).updateChildValues(["state": 1])
        completion()
    }
    
    func rejectTrips(uid: String, completion: @escaping(Error?, DatabaseReference) -> Void) {
        REF_TRIPS.child(uid).setValue(nil, withCompletionBlock: completion);
    }
    
    func completeTrips(uid: String, completion: @escaping(Error?, DatabaseReference) -> Void) {
        REF_TRIPS.child(uid).updateChildValues(["state": 3], withCompletionBlock: completion)
    }
    
    func declineTrips(uid: String, completion: @escaping(Error?, DatabaseReference) -> Void) {
        REF_TRIPS.child(uid).updateChildValues(["state": 4], withCompletionBlock: completion)
    }
    
    func RideFinished(uid: String, completion: @escaping(Trip?) -> Void ) {
        REF_TRIPS.observeSingleEvent(of:.childChanged) { (snapshot) in
            guard let dictionary = snapshot.value as? [String: Any] else { return }
            let uid = snapshot.key
            let trip = Trip(passengerUid: uid, dictionary: dictionary)
            completion(trip)
        }
        
        REF_TRIPS.observeSingleEvent(of: .childRemoved) {(snapshot) in
            completion(nil)
        }
    }
}
