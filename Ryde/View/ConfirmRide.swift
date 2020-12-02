//
//  ConfirmRide.swift
//  Ryde
//
//  Created by KEVIN ROMANO on 5/17/20.
//  Copyright © 2020 KEVIN ROMANO. All rights reserved.
//

import UIKit
import MapKit

protocol ConfirmRideDelegate: class {
    func handleAcceptRide(_ view: ConfirmRide)
    func handleRejectRide(_ view: ConfirmRide)
}

class ConfirmRide: UIView {
    
    weak var delegate: ConfirmRideDelegate?
    
    var lat: Double?
    var lng: Double?
    
    private let mapView = MKMapView()
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 18)
        label.text = "INCOMING REQUEST:"
        label.textAlignment = .center
        return label
    }()
    
    private let confirmButton: UIButton = {
        let button = UIButton(type: .system)
        button.backgroundColor = .systemGreen
        button.setTitle("Confirm", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize:20)
        button.addTarget(self, action: #selector(acceptRide), for: .touchUpInside)
        return button
    }()
    
    private let declineButton: UIButton = {
        let button = UIButton(type: .system)
        button.backgroundColor = .systemRed
        button.setTitle("Decline", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize:20)
        button.addTarget(self, action: #selector(rejectRide), for: .touchUpInside)
        return button
    }()
    

    init(frame:CGRect,lat:Double? = 37.8, lng:Double? = -122.8) {
        self.lat = lat
        self.lng = lng
        super.init(frame:frame)
        backgroundColor = .white
        // the primary title
        self.addSubview(titleLabel)
        titleLabel.anchor(top:topAnchor,paddingTop:20)
        titleLabel.centerX(inView:self)
        
        // the map view
        let coordinates = CLLocationCoordinate2D(latitude: self.lat ?? 37, longitude: self.lng ?? -123)
        let targetLocation = MKCoordinateRegion(center: coordinates, latitudinalMeters: 1000, longitudinalMeters: 1000)
        let placemark = MKPlacemark(coordinate: coordinates)
        let targetAnnotation = MKPointAnnotation()
        targetAnnotation.coordinate = coordinates
        mapView.setRegion(targetLocation, animated: false)
        mapView.addAnnotation(targetAnnotation)
        self.addSubview(mapView)
        mapView.setDimensions(height: 150,width: 150)
        mapView.anchor(top:titleLabel.bottomAnchor, paddingTop: 20, paddingBottom: 20)
        mapView.centerX(inView: self)
        mapView.layer.cornerRadius = 150 / 2
        
        // the confirm button
        self.addSubview(confirmButton)
        confirmButton.anchor(top:mapView.bottomAnchor,left: leftAnchor,
                             right:rightAnchor, paddingTop:20, paddingLeft: 10,
                             paddingBottom:10,paddingRight:10)
        confirmButton.centerX(inView:self)
        
        // the decline button
        self.addSubview(declineButton)
        declineButton.anchor(top:confirmButton.bottomAnchor,left: leftAnchor,
                             right:rightAnchor, paddingTop: 10, paddingLeft:10,
                             paddingBottom: 10,paddingRight: 10)
        declineButton.centerX(inView:self)
    }
    
    func setLocation(lat:Double?, lng:Double?) {
        mapView.annotations.forEach {(annotation) in
            if let anno = annotation as? MKPointAnnotation {
                mapView.removeAnnotation(anno)
            }
        }
        if mapView.overlays.count > 0 {
            // removes the polyline
            mapView.removeOverlay(mapView.overlays[0])
        }
        self.mapView.showAnnotations(self.mapView.annotations, animated: true)
        let coordinates = CLLocationCoordinate2D(latitude: lat ?? 37, longitude: lng ?? -123)
        let targetLocation = MKCoordinateRegion(center: coordinates, latitudinalMeters: 1000, longitudinalMeters: 1000)
        let placemark = MKPlacemark(coordinate: coordinates)
        let targetAnnotation = MKPointAnnotation()
        targetAnnotation.coordinate = coordinates
        mapView.setRegion(targetLocation, animated: false)
        mapView.addAnnotation(targetAnnotation)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc func acceptRide() {
        delegate?.handleAcceptRide(self)
    }
    
    @objc func rejectRide() {
        delegate?.handleRejectRide(self)
    }
}
