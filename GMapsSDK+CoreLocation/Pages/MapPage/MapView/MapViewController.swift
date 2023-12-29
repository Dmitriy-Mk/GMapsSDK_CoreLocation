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
    private var locationManager: CLLocationManager!
    private var mapView: GMSMapView!
    private var currentLocation: CLLocation?
    private var selectedPlace: GMSPlace?
    private let locationDetails = LocationDetails(preciseLocationZoomLevel: 15.0,
                                                  aproximateLocationZoomLevel: 10.0)
    var presenter: MapViewOutput?
    
    // MARK: - UI objects and setups
    private let getPlacesButton = UIButton(type: .system)
    
    private func addGetPlacesButtonAction() {
        getPlacesButton.addAction(UIAction(handler: { [weak self] _ in
            guard let strongSelf = self else { return }
            if let placesVC = PlacesModuleAssembly.assemble() as? PlacesViewController {
                strongSelf.navigationController?.pushViewController(placesVC, animated: true)
                placesVC.dataPassingDelegate = self
            }
        }), for: .touchUpInside)
    }
    
    private func setupGetPlacesButton() {
        view.addSubview(getPlacesButton)

        getPlacesButton.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        getPlacesButton.setTitle("Get Places", for: .normal)
        getPlacesButton.setTitleColor(.gray, for: .normal)
        getPlacesButton.frame.origin = CGPoint(x: view.frame.minX + 75, y: view.frame.maxY - 100)
        getPlacesButton.frame.size = CGSize(width: view.frame.width * 0.6, height: 60)
        getPlacesButton.layer.cornerRadius = 8.0
        getPlacesButton.layer.borderWidth = 1.0
        getPlacesButton.layer.borderColor = UIColor.gray.cgColor
        getPlacesButton.backgroundColor = .white
        getPlacesButton.contentMode = .scaleAspectFit
        getPlacesButton.alpha = 1.0
        getPlacesButton.isHidden = false

    }
    
    // MARK: - Lifecycle
    override func loadView() {
        super.loadView()
        presenter?.loadView()
        self.view = mapView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addGetPlacesButtonAction()
        locationManager = CLLocationManager()
        locationManager.delegate = self
    }
    
    @objc private func onTimerUpdate () {
        print("Timer expired!")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        setupGetPlacesButton()
        if let place = selectedPlace {
            guard let name = selectedPlace?.name else { return }
            guard let address = selectedPlace?.formattedAddress else { return }
            guard let currentLocation else { return }
            let strArray = [
                name,
                address
            ]
            
            mapView.clear()
            
            do {
                try presenter?.drawRoute(map: mapView,
                                         destInfo: strArray,
                                         origin: currentLocation.coordinate,
                                         destination: place.coordinate)
            } catch URLError.urlGetError {
                print("Cant get current route via URL!")
            } catch {
                print(error)
            }
        }
    }
    
    //MARK: - Business logic
    private func setupLocationManager() {
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
        self.locationManager.startUpdatingLocation()
        self.locationManager.distanceFilter = 70
    }
    
    private func getUserPlaceMark(by location: CLLocation) throws {
        let geocoder = GMSGeocoder()
        let passedError: Error? = nil
        
        geocoder.reverseGeocodeCoordinate(location.coordinate) { (response, error) in
            if let error = error {
                print("Reverse geocoding failed with error: \(error.localizedDescription)")
                return
            }
            
            guard let result = response?.firstResult() else {
                print("No results found")
                return
            }
            
            var addressComponents: [String] = []
            
            if let thoroughfare = result.thoroughfare {
                addressComponents.append(thoroughfare)
                print(thoroughfare)
            }
            
            if let subLocality = result.subLocality {
                addressComponents.append(subLocality)
                print(subLocality)
            }
            
            if let city = result.locality {
                addressComponents.append(city)
                print(city)
            }
            
            if let postalCode = result.postalCode {
                addressComponents.append(postalCode)
                print(postalCode)
            }
            
            if let country = result.country {
                addressComponents.append(country)
                print(country)
            }
            
            let address = addressComponents.joined(separator: ", ")
            print("Current Address: \(address)")
        }
        
        guard passedError == nil else {
            print(passedError ?? "")
            throw ReverseGeocodingError.errorWhenReverseLocation
        }
    }
}

// MARK: - Extensions
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
        if let currentLocation: CLLocation = locations.last {
            let zoomLevel = locationManager.accuracyAuthorization == .fullAccuracy ? locationDetails.preciseLocationZoomLevel : locationDetails.aproximateLocationZoomLevel
            let camera = GMSCameraPosition(latitude: currentLocation.coordinate.latitude,
                                           longitude: currentLocation.coordinate.longitude,
                                           zoom: zoomLevel)
            
            do {
                try self.getUserPlaceMark(by: currentLocation)
            } catch ReverseGeocodingError.errorWhenReverseLocation {
                print("Can't Reverse CLLocation to CLPlaceMark!")
            } catch {
                print("Something whent wrong with Geocoding!")
            }
            
            self.currentLocation = currentLocation
            
            if mapView.isHidden {
                mapView.isHidden = false
                mapView.camera = camera
            } else {
                mapView.animate(to: camera)
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        locationManager.stopUpdatingLocation()
        print(error.localizedDescription)
    }
}

// MARK: - Pass Selected Place
extension MapViewController: PassLikelyPlaceDelegate {
    func passingSelectedPlace(_ place: GMSPlace) {
        selectedPlace = place
    }
}

// MARK: - Model View Input
extension MapViewController: MapViewInput {
    func loadMapView(_ mapView: GMSMapView) {
        self.mapView = mapView
    }
}
