//
//  MapViewOutput.swift
//  GMapsSDK+CoreLocation
//
//  Created by Dmitriy Mkrtumyan on 27.12.23.
//

import Foundation
import GoogleMaps

protocol MapViewOutput: AnyObject {
    func loadView()
    func drawRoute(map: GMSMapView,
                   destInfo: [String],
                   origin: CLLocationCoordinate2D,
                   destination: CLLocationCoordinate2D) throws
}
