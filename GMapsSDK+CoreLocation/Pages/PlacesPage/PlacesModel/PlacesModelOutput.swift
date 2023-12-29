//
//  PlacesModelOutput.swift
//  GMapsSDK+CoreLocation
//
//  Created by Dmitriy Mkrtumyan on 29.12.23.
//

import GooglePlaces

protocol PlacesModelOutput: AnyObject {
    func getPlaces(_ places: [GMSPlace])
}
