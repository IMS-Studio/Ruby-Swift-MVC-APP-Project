//
//  Trip.swift
//  Ryde
//
//  Created by KEVIN ROMANO on 5/14/20.
//  Copyright © 2020 KEVIN ROMANO. All rights reserved.
//

import CoreLocation

struct Trip {
    var passengerCoordinates: CLLocationCoordinate2D!
    var goalCoordinates: CLLocationCoordinate2D!
    let passengerUid: String!
    var driverUid: String?
    var state: TripState!

    init(passengerUid: String, dictionary: [String: Any]) {
        self.passengerUid = passengerUid
        
        if let passengerCoordinates = dictionary["pickupCoordinates"] as? NSArray {
            guard let lat = passengerCoordinates[0] as? CLLocationDegrees else { return }
            guard let lng = passengerCoordinates[1] as? CLLocationDegrees else { return }
            self.passengerCoordinates = CLLocationCoordinate2D(latitude: lat, longitude: lng)
        }
        
        if let goalCoordinates = dictionary["destinationCoordinates"] as? NSArray {
            guard let lat = goalCoordinates[0] as? CLLocationDegrees else { return }
            guard let lng = goalCoordinates[1] as? CLLocationDegrees else { return }
            self.goalCoordinates = CLLocationCoordinate2D(latitude: lat, longitude: lng)
        }
        
        self.driverUid = dictionary["driverUid"] as? String ?? ""
        
        if let state = dictionary["state"] as? Int {
            self.state = TripState(rawValue: state)
        }
    }
}

enum TripState: Int {
    case requested
    case accepted
    case inProgress
    case completed
    case rejected
}
