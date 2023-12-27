//
//  MapViewInput.swift
//  GMapsSDK+CoreLocation
//
//  Created by Dmitriy Mkrtumyan on 27.12.23.
//

import GoogleMaps

protocol MapViewInput: AnyObject {
    func loadMapView(_ mapView: GMSMapView)
}
