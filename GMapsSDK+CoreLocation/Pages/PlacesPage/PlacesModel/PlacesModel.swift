//
//  PlacesModel.swift
//  GMapsSDK+CoreLocation
//
//  Created by Dmitriy Mkrtumyan on 29.12.23.
//

import GooglePlaces

final class PlacesModel: PlacesModelInput {
    
    private var placesClient: GMSPlacesClient!
    private var likelyPlaces: [GMSPlace] = []
    weak var presenter: PlacesModelOutput!
    
    func requestPlaces() {
        
        let placeFields: GMSPlaceField = [.name, .formattedAddress, .coordinate]
        
        placesClient = GMSPlacesClient.shared()
        
        likelyPlaces.removeAll()
        
        placesClient.findPlaceLikelihoodsFromCurrentLocation(withPlaceFields: placeFields) {
            [weak self] placeLikelihoods, error in
            
            guard let strongSelf = self else {return}
            guard error == nil else {
                print("Current place error: \(error?.localizedDescription ?? "Unknowed Error Was Accure!")")
                return
            }
            guard let placeLikelihoods = placeLikelihoods else {
                print("No places found.")
                return
            }
            
            for likelihood in placeLikelihoods {
                let place = likelihood.place
                strongSelf.likelyPlaces.append(place)
            }
        }
        
        presenter.getPlaces(likelyPlaces)
    }
}
