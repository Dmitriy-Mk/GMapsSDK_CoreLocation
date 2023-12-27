//
//  MapModel.swift
//  GoogleSDK
//
//  Created by Dmitriy Mkrtumyan on 21.11.23.
//

import GoogleMaps

// MARK: - Data
struct LocationDetails {
    var preciseLocationZoomLevel: Float
    var aproximateLocationZoomLevel: Float
    var coordinates: Coordinates?
}

struct Coordinates {
    var latitude: Double
    var longitude: Double
}

// MARK: - Declaration
final class MapModel {
    private let locationDetails = LocationDetails(preciseLocationZoomLevel: 15.0,
                                                  aproximateLocationZoomLevel: 10.0,
                                                  coordinates: Coordinates(
                                                    latitude: -33.869405,
                                                    longitude: 152.199))
    weak var presenter: MapPresenter?
}

extension MapModel: MapModelInput {
    
    func setupMapView() {
        var mapView = GMSMapView()
        let zoomLevel = locationDetails.aproximateLocationZoomLevel
        guard let latitude = locationDetails.coordinates?.latitude else { return }
        guard let longitude = locationDetails.coordinates?.longitude else { return }

        let camera = GMSCameraPosition(latitude: latitude,
                                       longitude: longitude,
                                       zoom: zoomLevel)
        
        mapView = GMSMapView()
        mapView.camera = camera
        mapView.settings.myLocationButton = true
        mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        mapView.isMyLocationEnabled = true
        mapView.isHidden = true
        
        presenter?.completedMapView(mapView)
    }
}
