//
//  PlacesViewInput.swift
//  GMapsSDK+CoreLocation
//
//  Created by Dmitriy Mkrtumyan on 29.12.23.
//

import GooglePlaces

protocol PlacesViewInput: AnyObject {
    func reloadTableView(with datasource: [GMSPlace])
}
