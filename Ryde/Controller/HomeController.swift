//
//  HomeController.swift
//  Ryde
//
//  Created by KEVIN ROMANO on 5/8/20.
//  Copyright © 2020 KEVIN ROMANO. All rights reserved.
//

import UIKit
import Firebase
import MapKit

private let reuseIdentifier = "LocationCell"
private let annotationIdentifier  = "DriverAnnotation"

private enum ActionButtonConfiguration {
    case activeMenu
    case exitActionView
    case dismissSideMenu
    init() {
        self = .activeMenu
    }
}

class HomeController: UIViewController {
    
    // MARK: - Properties
    private var confirmRide = ConfirmRide(frame: .zero)
    private var rideProgress = RideProgress()
    private var passengerProgress = PassengerProgress()
    private let mapView = MKMapView()
    private var notificationModal = NotificationModal(frame:.zero, message: "")
    private let locationManager = LocationHandler.shared.locationManager
    private let locationActivationView = ActivateInputLocationView()
    private let rideSelectionView = RideSelectionView()
    private let sideMenu = SideMenu()
    private let locationInputView = LocationInputView()
    private let tableView = UITableView()
    private var searchResults = [MKPlacemark]()
    private var loadingSpinner = UIActivityIndicatorView()
    private var loadingLabel = UILabel()
    private final let locationInputViewHeight: CGFloat = 150
    private final let rydeSelectionHeight: CGFloat = 300
    private final let rideProgressHeight: CGFloat = 200
    private final let sideMenuWidth: CGFloat = 200
    private final let confirmRideHeight: CGFloat = 400
    private final let passengerProgressHeight: CGFloat = 100
    private var actionButtonConfig = ActionButtonConfiguration()
    private var route: MKRoute?
    
    /* fetches drivers if user type == passenger
     observes for changes in DB if user type == driver */
    private var user: User? {
        didSet {
            locationInputView.user = user
            if user?.accountType == .passenger {
                fetchDrivers()
                configureLocationInputActivationView()
            } else {
                observeTrips()
            }
        }
    }
    
    /* adds confirmRide and observes for further DB update
     if user type == driver */
    private var trip: Trip? {
        didSet {
            if user?.accountType == .driver && trip?.state.rawValue == 0 {
                confirmRide.setLocation(lat: trip?.passengerCoordinates.latitude,
                                          lng:trip?.passengerCoordinates.longitude)
                confirmRide.alpha = 1
                observeUpdateTrips()
            }
        }
    }
    
    /* the hamburger button */
    private let actionButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(#imageLiteral(resourceName: "baseline_menu_black_36dp").withRenderingMode(.alwaysOriginal), for: .normal)
        button.addTarget(self, action: #selector(actionButtonPressed), for: .touchUpInside)
        return button
    }()
    
    // MARK: - Lifecycle
    
    /* The didMount function */
    override func viewDidLoad() {
        super.viewDidLoad()
        checkIfUserIsLoggedIn()
        enableLocationServices()
    }
    
    
    
    
    // MARK: - Selectors
    
    
    
    
    /* the button pressed handler */
    @objc func actionButtonPressed () {
        switch actionButtonConfig {
        case .activeMenu:
            // This is where we add the side menu
            locationActivationView.alpha = 0
            configureActionButton(config: .dismissSideMenu)
            UIView.animate(withDuration: 0.3) {
                self.sideMenu.frame.origin.x =  0
            }
            
        case .exitActionView:
            reappearSearchBar()
        case .dismissSideMenu:
            configureActionButton(config: .activeMenu)
            // self.sideMenu.alpha = 0
            UIView.animate(withDuration: 0.3) {
                self.sideMenu.frame.origin.x =  -self.view.frame.width
            }
            UIView.animate(withDuration: 0.3) {
                self.locationActivationView.alpha = 1
            }
            
        }
    }
    
    
    
    // MARK: - API
    
    func observeTrips() {
        Service.shared.observeTrips { trip in
            self.trip = trip
        }
    }
    
    func observeUpdateTrips() {
        Service.shared.observeUpdateTrips { trip in
            if (trip == nil && self.confirmRide.alpha == 1) {
                self.displayModal(description: "Time limit request exceed ")
                self.confirmRide.alpha = 0
                Service.shared.rejectTrips(uid: Auth.auth().currentUser?.uid ?? "") { (err, ref) in
                    print("Session: Removed trip")
                }
            }
            else {
                if trip?.state == TripState(rawValue: 1) /*&& self.confirmRide.isDescendant(of: self.view)*/ {
                    self.confirmRide.alpha = 0
                    self.rideProgress.alpha = 1
                    let passengerPlacemark = MKPlacemark(coordinate: trip?.passengerCoordinates! ?? CLLocationCoordinate2D(latitude: 10, longitude: 10))
                    let passengerItem = MKMapItem(placemark: passengerPlacemark)
                    self.createPolyline(toDestination: passengerItem)
                    let annotations = MKPointAnnotation()
                    annotations.coordinate = passengerPlacemark.coordinate
                    // adds the annotation on the destionation
                    self.mapView.addAnnotation(annotations)
                    self.mapView.zoomToFit(annotation: [annotations])
                    Service.shared.RideFinished(uid:trip?.passengerUid ?? "", completion: { (trip) in
                        if trip != nil && trip?.state == TripState(rawValue: 4) {
                            self.displayModal(description: "Passenger has declined the request")
                            self.removeAnnotationsAndOverlays()
                            self.rideProgress.alpha = 0
                            Service.shared.rejectTrips(uid: trip?.passengerUid ?? "") { (err, ref) in }
                        }
                        if trip == nil {}
                    })
                    
                }
                else {
                    self.confirmRide.alpha = 0
                }
            }
        }
    }
    
    /* function that validates whether a user is logged in or not */
    func checkIfUserIsLoggedIn() {
        if Auth.auth().currentUser?.uid == nil {
            DispatchQueue.main.async {
                let nav = UINavigationController(rootViewController: LoginController())
                self.present(nav, animated:true, completion: nil)
            }
            return
        }
        configure()
    }
    
    /* function that redirects the user to the login page
     if the user logs out from one's account */
    func logOut() {
        do {
            try Auth.auth().signOut()
            DispatchQueue.main.async {
                // remove all driver annotations from the mapView
                self.mapView.removeAnnotations(self.mapView.annotations)
                // remove mapView and sideMenu from the view's subview
                self.mapView.removeFromSuperview()
                self.sideMenu.removeFromSuperview()
                self.rideSelectionView.removeFromSuperview()
                self.confirmRide.removeFromSuperview()
                self.passengerProgress.removeFromSuperview()
                self.rideProgress.removeFromSuperview()
                self.actionButton.removeFromSuperview()
                self.tableView.removeFromSuperview()
                self.notificationModal.removeFromSuperview()
                self.loadingLabel.removeFromSuperview()
                self.loadingSpinner.removeFromSuperview()
                // change the rootViewController to the logincontroller
                let nav = UINavigationController(rootViewController: LoginController())
                self.present(nav, animated:true, completion: nil)
            }
        } catch {
            print("Session: Error attempting to sign out")
        }
        
    }

    /* function that fetches user's data from the Firebase */
    func fetchUserData() {
        guard let currentUid = Auth.auth().currentUser?.uid else { return }
        Service.shared.fetchUserData(uid:currentUid) { user in
            self.user = user
        }
    }
    

    /* fetch drivers if the user is a passenger */
    func fetchDrivers() {
        guard let location = locationManager?.location else { return }
        Service.shared.fetchDrivers(location: location) { (pilot) in
            guard let coordinate = pilot.location?.coordinate else { return }
            let annotation = DriverAnnotation(uid: pilot.uid, coordinate: coordinate)
            var isDriverVisible: Bool {
                return self.mapView.annotations.contains { annotation -> Bool in
                    guard let driverAnnotation = annotation as? DriverAnnotation else { return false }
                    if driverAnnotation.uid == pilot.uid {
                        driverAnnotation.updateAnnotationPosition(withCoordinate: coordinate)
                        return true
                    }
                    return false
                }
            }
            if !isDriverVisible {
                self.mapView.addAnnotation(annotation)
            }
        }
    }
    
    /* display the popup modal after the user selects the destination */
    func showRideSelectionView(shouldShow: Bool, destination: MKPlacemark? = nil) {
        let yOrigin = shouldShow ? self.view.frame.height - self.rydeSelectionHeight : self.view.frame.height
        
        if shouldShow {
            guard let destination = destination else { return }
            rideSelectionView.destination = destination
        }
        
        UIView.animate(withDuration: 0.3) {
            self.rideSelectionView.frame.origin.y = yOrigin
        }
    }
    
    
    
    // MARK: - Helper Functions
    
    
    
    func configure() {
        configureUI()
        fetchUserData()
    }
    
    fileprivate func configureActionButton(config: ActionButtonConfiguration) {
        switch config {
        case  .activeMenu:
            self.actionButton.setImage(#imageLiteral(resourceName: "baseline_menu_black_36dp").withRenderingMode(.alwaysOriginal), for: .normal)
            self.actionButtonConfig = .activeMenu
        case  .exitActionView:
            actionButton.setImage(#imageLiteral(resourceName: "baseline_arrow_back_black_36dp").withRenderingMode(.alwaysOriginal), for: .normal)
            actionButtonConfig = .exitActionView
        case .dismissSideMenu:
            actionButton.setImage(#imageLiteral(resourceName: "baseline_clear_white_36pt_2x"), for: .normal)
            self.actionButtonConfig = .dismissSideMenu
        }

    }
    
    func configureUI() {
        configureMapView()
        configureRideSelectionView()
        configureSideMenu()
        configurePassengerView()
        configureConfirmRide()
        configureRideProgress()
        configureMenuButton()
        configureTableView()
        configureNotificationModal()
        configureLoadingSpinner()
    }
    
    /* adds the searchbar to the view */
    func configureLocationInputActivationView() {
        view.addSubview(locationActivationView)
        locationActivationView.centerX(inView: view)
        locationActivationView.setDimensions(height: 50, width: view.frame.width - 64)
        locationActivationView.anchor(top: actionButton.bottomAnchor, paddingTop: 32)
        // hidden as default
        locationActivationView.alpha = 0
        locationActivationView.delegate = self
        
        // display the search bar via animation
        UIView.animate(withDuration: 1) {
            self.locationActivationView.alpha = 1
        }
    }
    
    func configureConfirmRide() {
        confirmRide.alpha = 0
        view.insertSubview(confirmRide, belowSubview: sideMenu)
        confirmRide.delegate = self
        confirmRide.frame = CGRect(x: 0, y: view.frame.height - confirmRideHeight,
                                  width: view.frame.width, height: confirmRideHeight)
    }
    
    func configureRideProgress() {
        self.rideProgress.alpha = 0
        self.view.insertSubview(self.rideProgress, aboveSubview: self.confirmRide)
        self.rideProgress.delegate = self
        self.rideProgress.frame = CGRect(x:0, y:view.frame.height - rideProgressHeight,
                                         width: view.frame.width, height: rideProgressHeight)
    }
    
    /* adds the mapView the views */
    func configureMapView() {
        view.addSubview(mapView)
        mapView.frame = view.frame
        mapView.showsUserLocation = true
        mapView.userTrackingMode = .follow
        mapView.delegate = self
    }
    
    func configureLoadingSpinner() {
        loadingSpinner = UIActivityIndicatorView(style: .whiteLarge)
        loadingLabel = UILabel()
        loadingLabel.text = "Looking for drivers..."
        loadingLabel.font = UIFont.systemFont(ofSize: 18)
        loadingLabel.textColor = .white
        self.view.addSubview(loadingSpinner)
        loadingSpinner.centerX(inView: self.view)
        loadingSpinner.centerY(inView: self.view)
        loadingSpinner.anchor(paddingBottom:20)
        self.view.addSubview(loadingLabel)
        loadingLabel.centerX(inView:self.view)
        loadingLabel.anchor(top: loadingSpinner.bottomAnchor)
        //loadingSpinner.anchor(top: self.view.safeAreaLayoutGuide.topAnchor)
        loadingSpinner.alpha = 0
        loadingLabel.alpha = 0
    }
    
    func addLoadingSpinner() {
        loadingSpinner.alpha = 1
        loadingLabel.alpha = 1
        loadingSpinner.startAnimating()
    }
    
    func dismissLoadingSpinner() {
        loadingSpinner.stopAnimating()
        loadingSpinner.alpha = 0
        loadingLabel.alpha = 0
    }
    
    /* displays message modal */
    func displayModal(description: String) {
        notificationModal.setDescription(message: description)
        var counter: Int = 0
        UIView.animate(withDuration: 0.3) { self.notificationModal.alpha = 1 }
        Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { timer in
            counter += 1
            if counter == 1 {
                timer.invalidate()
                UIView.animate(withDuration: 0.3) { self.notificationModal.alpha = 0 }
            }
        }
    }
    
    /* adds the UILabel to the view */
    func configureLocationInputView() {
        locationInputView.delegate = self
        view.addSubview(locationInputView)
        locationInputView.anchor(top: view.topAnchor, left: view.leftAnchor, right: view.rightAnchor, height: 150)
        locationInputView.alpha = 0
        UIView.animate(withDuration: 0.5, animations: {
            self.locationInputView.alpha = 1
        }) { _ in
            UIView.animate(withDuration: 0.3, animations: {
                self.tableView.frame.origin.y = self.locationInputViewHeight
            })
        }
    }
    
    func configureModal() {
    }
    
    /* adds the side menu into the view */
    func configureSideMenu() {
        view.addSubview(sideMenu)
        sideMenu.delegate = self
        sideMenu.frame =  CGRect(x: -view.frame.width, y: 0,
                                 width: sideMenuWidth, height: view.frame.height)
    }
    
    /* adds the UI regarding the ride selection contents
     into the view*/
    func configureRideSelectionView() {
        view.addSubview(rideSelectionView)
        rideSelectionView.delegate = self
        rideSelectionView.frame = CGRect(x: 0, y: view.frame.height,
                                         width: view.frame.width, height: rydeSelectionHeight)
    }
    
    /* adds the menu button to the top-left-hand corner of the view*/
    func configureMenuButton() {
        view.addSubview(actionButton)
        actionButton.anchor(top: view.safeAreaLayoutGuide.topAnchor, left: view.leftAnchor,
                            paddingTop: 16, paddingLeft: 20, width: 30, height: 30)
    }
    
    /* adds the UITableView into the view */
    func configureTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.register(LocationTableCell.self, forCellReuseIdentifier: reuseIdentifier)
        tableView.rowHeight = 60
        tableView.tableFooterView = UIView()
        
        let height = view.frame.height - locationInputViewHeight
        tableView.frame = CGRect(x: 0, y: view.frame.height, width: view.frame.width, height: height)
        view.addSubview(tableView)
    }
    
    func configurePassengerView() {
        self.passengerProgress.delegate = self
        self.passengerProgress.alpha = 0
        self.passengerProgress.frame = CGRect(x: 0, y: self.view.frame.height - self.passengerProgressHeight,
                                    width: self.view.frame.width, height: self.passengerProgressHeight)
        self.view.insertSubview(self.passengerProgress, belowSubview: self.sideMenu)
    }
    
    func configureNotificationModal() {
        self.notificationModal.alpha = 0
        self.view.addSubview(self.notificationModal)
        self.notificationModal.anchor(paddingTop:10, paddingLeft: 20, paddingBottom: 10,
                     paddingRight: 20,width:self.view.frame.width - 20, height:100)
        self.notificationModal.centerX(inView: self.view)
        self.notificationModal.centerY(inView: self.view)
    }
    
    /* dismisses UITableView from the view */
    func exitLocationInputView(completion: ((Bool) -> Void)? = nil) {
        UIView.animate(withDuration: 0.3, animations: {
            self.locationInputView.alpha = 0
            self.tableView.frame.origin.y = self.view.frame.height
            self.locationInputView.removeFromSuperview()
        }, completion: completion)
    }
    
    /* displays searchbar via changing alpha to 1*/
    func reappearSearchBar() {
         removeAnnotationsAndOverlays()
         UIView.animate(withDuration: 0.3) {
             self.locationActivationView.alpha = 1
             self.configureActionButton(config: .activeMenu)
             self.showRideSelectionView(shouldShow:false)
         }
    }
    
}




    // MARK: - MapView Helper Functions


    
    private extension HomeController {
        func searchBy(naturalLanguageQuery: String, completion: @escaping([MKPlacemark]) -> Void) {
            var queryResults = [MKPlacemark]()
            
            let request = MKLocalSearch.Request()
            request.region = mapView.region
            // query that the user entered in the UILabel
            request.naturalLanguageQuery = naturalLanguageQuery
            let search = MKLocalSearch(request: request)
            search.start { (response,error) in
                // the query results
                guard let response = response else { return }
                /* appends all of the given fetched results
                into the queryResults array */
                response.mapItems.forEach({ item in
                    queryResults.append(item.placemark)
                })
                
                completion(queryResults)
            }
        }
    
    
    /* Adds a polyline between the passenger and the specified
     destination */
    func createPolyline(toDestination destination: MKMapItem) {
        let request = MKDirections.Request()
        request.source = MKMapItem.forCurrentLocation()
        request.destination = destination
        request.transportType = .automobile
        
        let directionRequest = MKDirections(request:request)
        directionRequest.calculate { (response, error) in
            guard let response = response else { return }
            self.route = response.routes[0]
            // generates a polyline
            guard let polyline = self.route?.polyline else { return }
            self.mapView.addOverlay(polyline)
        }
        
    }
        /* Dismisses the polyline and the location marker
         after pressing the back button */
        func removeAnnotationsAndOverlays() {
        // iterates through the mapView.annotation
        // and removes them from the mapView
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
    }
}

// MARK: - MarkViewDelegate

extension HomeController: MKMapViewDelegate {
    /* custom annotation that represents the driver */
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if let annotation = annotation as? DriverAnnotation {
            let view = MKAnnotationView(annotation: annotation, reuseIdentifier: annotationIdentifier)
            view.image = #imageLiteral(resourceName: "driver")
            return view
        }
        return nil
    }
    
    /* builds an overlay to the polyline.
    In this, it displays as a black line */
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if let route = self.route {
            let polyline = route.polyline
            let lineRenderer = MKPolylineRenderer(overlay: polyline)
            lineRenderer.strokeColor = .black
            lineRenderer.lineWidth = 4
            return lineRenderer
        }
        return MKOverlayRenderer()
    }
}

// MARK: LocationServices

extension HomeController {
    func enableLocationServices() {
        switch CLLocationManager.authorizationStatus() {
        case .notDetermined:
            locationManager?.requestWhenInUseAuthorization()
        case .restricted, .denied:
            break
        case .authorizedAlways:
            locationManager?.startUpdatingLocation()
            locationManager?.desiredAccuracy = kCLLocationAccuracyBest
        case .authorizedWhenInUse:
            locationManager?.requestAlwaysAuthorization()
        @unknown default:
            break
        }
    }

}


extension HomeController: ActivateInputLocationViewDelegate {
    /* displays the UILabel */
    func presentLocationInputView() {
        locationActivationView.alpha = 0
        configureLocationInputView()
    }
}

extension HomeController: LocationInputViewDelegate {
    /* populates query results for the update user query */
    func computeQuery(query: String) {
        searchBy(naturalLanguageQuery: query, completion: { results in
            self.searchResults = results
            self.tableView.reloadData()
        })
    }
    
    /* Dismisses UILabel from the views */
    func terminateLocationInputView() {
        exitLocationInputView()
    }
    
    /* display UILabel if back button is pressed
     via the animation function */
    func ExitLocationInputView() {
        exitLocationInputView {_ in
            UIView.animate(withDuration: 0.5, animations: {
                self.locationActivationView.alpha = 1
            })
        }
    }
}

// MARK: - UITableViewDelegate/DataSource

extension HomeController: UITableViewDelegate, UITableViewDataSource {
    // the title of tables
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Results"
    }
    
    // total number of tabel cells to populate in the first UITableView
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    // displays 2 cells if the query results is empty
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return section == 0 ? searchResults.count : 0
    }
    // populate table cells with query results
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath) as! LocationTableCell
        if indexPath.section == 0 {
            cell.placemark = searchResults[indexPath.row]
        }
        return cell
    }
    
    //
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // selected results by the user
        let selectedPlacemark = searchResults[indexPath.row]
        // changes the button into the exit button
        configureActionButton(config: .exitActionView)
        // the selected result's location information
        let destination = MKMapItem(placemark: selectedPlacemark)
        createPolyline(toDestination: destination)
        
        // Dismisses the UILabel
        exitLocationInputView {_ in
            let annotation = MKPointAnnotation()
            annotation.coordinate = selectedPlacemark.coordinate
            // adds the annotation on the destionation
            self.mapView.addAnnotation(annotation)
            self.mapView.selectAnnotation(annotation,animated:true)
        
            // stores driver annotations, based on the first parameter of the
            // self.mapView.annotations.filter function
            let annotations = self.mapView.annotations.filter( {!$0.isKind(of:
                DriverAnnotation.self)})
            self.mapView.zoomToFit(annotation: annotations)
            
            self.showRideSelectionView(shouldShow: true, destination: selectedPlacemark)
            
        }
        
    }
        
}

extension HomeController: RideSelectionViewDelegate {
    // The upload trip function
    func uploadTrip(_ view: RideSelectionView) {
        guard let pickupCoordinates = locationManager?.location?.coordinate else { return }
        guard let destinationCoordinates = view.destination?.coordinate else { return }
        Service.shared.uploadTrip(pickupCoordinates, destinationCoordinates) { (error, ref) in
            if let error = error {
                return
            }
            self.addLoadingSpinner()
            self.mapView.alpha = 0.5
            self.rideSelectionView.backgroundColor = .systemGray3
            self.actionButton.isEnabled = false
            Service.shared.observeUpdateTrips { trip in
                if (trip == nil && self.mapView.alpha == 0.5) {
                    self.showRideSelectionView(shouldShow: false)
                    self.mapView.alpha = 1
                    self.actionButton.isEnabled = true
                    self.configureActionButton(config: .activeMenu)
                    self.rideSelectionView.backgroundColor = .white
                    self.dismissLoadingSpinner()
                    self.displayModal(description: "Drivers not found... Please try again")
                    var counter: Int = 0
                    Timer.scheduledTimer(withTimeInterval:1, repeats: true) { timer in
                        counter += 1
                        if counter == 1 {
                            timer.invalidate()
                            self.reappearSearchBar()
                        }
                    }
                    Service.shared.rejectTrips(uid: Auth.auth().currentUser?.uid ?? "") { (err, ref) in
                        print("Session: trip removed")
                    }
                }
                else {
                    if (trip?.state.rawValue == 1) {
                        self.showRideSelectionView(shouldShow: false)
                        self.mapView.alpha = 1
                        self.rideSelectionView.backgroundColor = .white
                        self.actionButton.isEnabled = true
                        self.configureActionButton(config: .activeMenu)
                        self.actionButton.alpha = 0
                        self.dismissLoadingSpinner()
                        self.removeAnnotationsAndOverlays()
                        self.displayModal(description: "Ride Confirmed! Driver will arrive shortly")
                        var counter: Int = 0
                        Timer.scheduledTimer(withTimeInterval:1, repeats: true) { timer in
                            // self.reappearSearchBar()
                            counter += 1
                            if counter == 1 {
                                timer.invalidate()
                                self.passengerProgress.alpha = 1
                                Service.shared.RideFinished(uid: Auth.auth().currentUser!.uid) { trip in
                                    if trip == nil && self.passengerProgress.alpha == 1 {
                                        self.displayModal(description: "Driver has declined the request")
                                        UIView.animate(withDuration: 0.3) {
                                            self.actionButton.alpha = 1
                                        }
                                        self.reappearSearchBar()
                                        self.passengerProgress.alpha = 0
                                    }
                                    else if trip != nil && trip?.state == TripState(rawValue: 3) {
                                        print("entered")
                                        self.displayModal(description: "Driver has arrived at your current location")
                                        UIView.animate(withDuration: 0.3) {
                                            self.actionButton.alpha = 1
                                        }
                                        self.reappearSearchBar()
                                        self.passengerProgress.alpha = 0
                                        Timer.scheduledTimer(withTimeInterval: 1, repeats: false) { timer in
                                            Service.shared.rejectTrips(uid: Auth.auth().currentUser?.uid ?? "") { (err, ref) in }
                                        }
                                        
                                    }
                                }
                            }
                        }
                        
                    }
                }
            
            }
            
        }
    }
    

}

extension HomeController: SideMenuDelegate {
    func logOutActivated(_ view: SideMenu) {
        configureActionButton(config: .activeMenu)
        logOut()
    }
}

extension HomeController: ConfirmRideDelegate {
    func handleAcceptRide(_ view: ConfirmRide) {
        Service.shared.acceptTrips(uid: self.trip?.passengerUid ?? "", completion: { () in })
        return
    }
    
    func handleRejectRide(_ view: ConfirmRide) {
        self.confirmRide.alpha = 0
        return
    }
}

extension HomeController: RideProgressDelegate {
    func handleFinishButton(_ view: RideProgress) {
        Service.shared.completeTrips(uid: self.trip?.passengerUid ?? "") { (err, ref) in
            self.removeAnnotationsAndOverlays()
            self.rideProgress.alpha = 0
        }
    }

    
    func handleDeclineButton(_ view: RideProgress) {
        Service.shared.rejectTrips(uid: self.trip?.passengerUid ?? "", completion: { (err, ref)  in
            self.removeAnnotationsAndOverlays()
            self.rideProgress.alpha = 0
        })
    }
}

extension HomeController: PassengerProgressDelegate {
    func handlePassengerDecline(_ view: PassengerProgress) {
        Service.shared.declineTrips(uid: Auth.auth().currentUser?.uid ?? "", completion:  { (err, ref) in
            self.passengerProgress.alpha = 0
            UIView.animate(withDuration: 0.3) {
                self.actionButton.alpha = 1
            }
            self.reappearSearchBar()
        })
    }
}
