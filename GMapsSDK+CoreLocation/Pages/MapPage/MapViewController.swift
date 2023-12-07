//
//  MapViewController.swift
//  GoogleSDK
//
//  Created by Dmitriy Mkrtumyan on 21.11.23.
//

import UIKit
import GoogleMaps
import GooglePlaces
import CoreLocation

final class MapViewController: UIViewController {
    // MARK: - Data
    private let coordinates = Coordinates(latitude: -33.869405,
                                  longitude: 152.199)
    private var locationManager: CLLocationManager!
    private var placesClient: GMSPlacesClient!
    private var mapView: GMSMapView!
    private var currentLocation: CLLocation?
    private var preciseLocationZoomLevel: Float = 15.0
    private var aproximateLocationZoomLevel: Float = 10.0
    private var likelyPlaces: [GMSPlace] = []
    private var selectedPlace: GMSPlace?
    private var addActionCounter: Int = 0
    
    // MARK: - UI objects and setups
    private let getPlacesButton = UIButton()
    
    private func addGetPlacesButtonAction() {
        if !(likelyPlaces.isEmpty) {
            addActionCounter += 1
            if addActionCounter == 1 {
                getPlacesButton.addAction(UIAction(handler: { [weak self] _ in
                    guard let strongSelf = self else { return }
                    let vc = PlacesViewController()
                    strongSelf.navigationController?.pushViewController(vc, animated: true)
                    vc.likelyPlaces = strongSelf.likelyPlaces
                    vc.dataPassingDelegate = self
                }), for: .touchUpInside)
            }
        }
    }
    
    private func setupGetPlacesButton() {
        getPlacesButton.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        getPlacesButton.setTitle("Get Places", for: .normal)
        getPlacesButton.setTitleColor(.gray, for: .normal)
        getPlacesButton.frame.size = CGSize(width: view.frame.width * 0.6, height: 60)
        getPlacesButton.layer.cornerRadius = 8.0
        getPlacesButton.layer.borderWidth = 1.0
        getPlacesButton.layer.borderColor = UIColor.gray.cgColor
        getPlacesButton.frame.origin = CGPoint(x: view.frame.minX + 75, y: view.frame.maxY - 100)
        getPlacesButton.backgroundColor = .white
        view.addSubview(getPlacesButton)
    }
    
    // MARK: - Lifecycle
    override func loadView() {
        super.loadView()
        setupGoogleMaps()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        locationManager = CLLocationManager()
        locationManager.delegate = self
        view.backgroundColor = .cyan
        setupGetPlacesButton()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if let place = selectedPlace {
            let marker = GMSMarker(position: place.coordinate)

            mapView.clear()

            marker.title = selectedPlace?.name
            marker.snippet = selectedPlace?.formattedAddress
            marker.map = mapView
            setupGooglePlaces()
        }
    }
    
    //MARK: - Business logic
    private func setupGoogleMaps() {
        let zoomLevel = aproximateLocationZoomLevel
        let camera = GMSCameraPosition(latitude: coordinates.latitude,
                                       longitude: coordinates.longitude,
                                       zoom: zoomLevel)
        mapView = GMSMapView()
        mapView.camera = camera
        mapView.settings.myLocationButton = true
        mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        mapView.isMyLocationEnabled = true
        mapView.frame = view.frame
        view = mapView
        mapView.isHidden = true
    }
    
    private func setupLocationManager() {
        self.locationManager.desiredAccuracy = kCLLocationAccuracyThreeKilometers
        self.locationManager.startUpdatingLocation()
        self.locationManager.distanceFilter = 30
    }
    
    private func setupGooglePlaces() {
        let placeFields: GMSPlaceField = [.name, .formattedAddress, .coordinate]
                
        placesClient = GMSPlacesClient.shared()
        
        likelyPlaces.removeAll()
        
        placesClient.findPlaceLikelihoodsFromCurrentLocation(withPlaceFields: placeFields) {
            [weak self] placeLikelihoods, error in
            
            guard let strongSelf = self else {return}
            guard error == nil else {
                print("Current place error: \(error?.localizedDescription ?? "Unknowed Error Was Accure!")")
                return
            }
            guard let placeLikelihoods = placeLikelihoods else {
                print("No places found.")
                return
            }
            
            for likelihood in placeLikelihoods {
                let place = likelihood.place
                strongSelf.likelyPlaces.append(place)
            }
            
            strongSelf.addGetPlacesButtonAction()
        }
    }
}

//MARK: - Extensions
extension MapViewController: CLLocationManagerDelegate {
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        let accuracy = manager.accuracyAuthorization
        let status = manager.authorizationStatus
        
        switch status {
        case .authorizedAlways, .authorizedWhenInUse:
            self.setupLocationManager()
            print("Location status is AUTHORIZED.")
        case .notDetermined:
            self.locationManager.requestWhenInUseAuthorization()
            print("Location status not determined.")
        case .denied:
            self.locationManager.requestWhenInUseAuthorization()
            print("Location access denied.")
        case .restricted:
            self.locationManager.requestWhenInUseAuthorization()
            print("Location access was restricted.")
        @unknown default:
            fatalError()
        }
        
        switch accuracy {
        case .fullAccuracy:
            print("Location accuracy is precise.")
        case .reducedAccuracy:
            print("Location accuracy is not precise.")
        @unknown default:
            fatalError()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let currentLocation: CLLocation = locations.first {
            let zoomLevel = locationManager.accuracyAuthorization == .fullAccuracy ? preciseLocationZoomLevel : aproximateLocationZoomLevel
            let camera = GMSCameraPosition(latitude: currentLocation.coordinate.latitude,
                                           longitude: currentLocation.coordinate.longitude,
                                           zoom: zoomLevel)
            
            if mapView.isHidden {
                mapView.isHidden = false
                mapView.camera = camera
            } else {
                mapView.animate(to: camera)
            }
            
            setupGooglePlaces()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        locationManager.stopUpdatingLocation()
        print(error.localizedDescription)
    }
}

//MARK: - Pass Selected Place
extension MapViewController: PassLikelyPlace {
    func passingSelectedPlace(_ place: GMSPlace) {
        selectedPlace = place
    }
}
