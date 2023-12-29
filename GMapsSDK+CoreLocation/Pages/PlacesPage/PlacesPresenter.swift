//
//  PlacesPresenter.swift
//  GMapsSDK+CoreLocation
//
//  Created by Dmitriy Mkrtumyan on 28.12.23.
//

import GooglePlaces


final class PlacesPresenter: PlacesViewOutput {
    
    private var likelyPlaces: [GMSPlace] = []
    private var model: PlacesModelInput!
    var placesCount: Int {
        likelyPlaces.count
    }
    
    init(model: PlacesModelInput) {
        self.model = model
    }
    
    func fetchPlaces() {
        model.requestPlaces()
    }
    
    func getPlace(at index: Int) -> GMSPlace {
        likelyPlaces[index]
    }
}

extension PlacesPresenter: PlacesModelOutput {
    
    func getPlaces(_ places: [GMSPlace]) {
        self.likelyPlaces = places
    }
}
