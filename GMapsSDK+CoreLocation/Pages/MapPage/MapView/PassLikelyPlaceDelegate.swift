//
//  PassLikelyPlaceDelegate.swift
//  GMapsSDK+CoreLocation
//
//  Created by Dmitriy Mkrtumyan on 29.12.23.
//

import GooglePlaces

protocol PassLikelyPlaceDelegate: AnyObject {
    func passingSelectedPlace(_ place: GMSPlace)
}
