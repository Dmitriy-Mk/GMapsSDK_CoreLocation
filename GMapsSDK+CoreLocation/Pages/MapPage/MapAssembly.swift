//
//  MapAssembly.swift
//  GMapsSDK+CoreLocation
//
//  Created by Dmitriy Mkrtumyan on 27.12.23.
//

import UIKit.UIView

final class MapAssembly {
    static func assembleModule() -> UIViewController {
        let view = MapViewController()
        let presenter = MapPresenter()
        let model = MapModel()
        
        view.presenter = presenter
        
        model.presenter = presenter
        
        presenter.view = view
        presenter.model = model
        
        return view
    }
}
