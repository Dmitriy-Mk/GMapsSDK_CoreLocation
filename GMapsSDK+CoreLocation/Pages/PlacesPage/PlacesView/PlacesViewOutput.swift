//
//  PlacesViewOutput.swift
//  GMapsSDK+CoreLocation
//
//  Created by Dmitriy Mkrtumyan on 29.12.23.
//

import GooglePlaces

protocol PlacesViewOutput: AnyObject {
    var placesCount: Int { get }
    func fetchPlaces()
    func getPlace(at index: Int) -> GMSPlace
}
