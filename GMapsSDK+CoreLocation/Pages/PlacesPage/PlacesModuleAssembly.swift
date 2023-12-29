//
//  PlacesModuleAssembly.swift
//  GMapsSDK+CoreLocation
//
//  Created by Dmitriy Mkrtumyan on 29.12.23.
//

import UIKit

final class PlacesModuleAssembly {
    
    static func assemble() -> UIViewController {
        
        let view = PlacesViewController()
        let model = PlacesModel()
        let presenter = PlacesPresenter(model: model)
        
        view.presenter = presenter
        
        model.presenter = presenter
        
        return view
    }
}
