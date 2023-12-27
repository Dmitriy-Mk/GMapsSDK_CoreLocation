//
//  MapModelOutput.swift
//  GMapsSDK+CoreLocation
//
//  Created by Dmitriy Mkrtumyan on 27.12.23.
//

import GoogleMaps

protocol MapModelOutput: AnyObject {
    func completedMapView(_ mapView: GMSMapView)
}
