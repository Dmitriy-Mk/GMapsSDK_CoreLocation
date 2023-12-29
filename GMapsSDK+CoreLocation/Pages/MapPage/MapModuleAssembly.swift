//
//  MapModuleAssembly.swift
//  GMapsSDK+CoreLocation
//
//  Created by Dmitriy Mkrtumyan on 27.12.23.
//

import UIKit.UIView

final class MapModuleAssembly {
    static func assembleModule() -> UIViewController {
        let model = MapModel()
        let presenter = MapPresenter(model: model)
        let view = MapViewController()
        
        view.presenter = presenter
        
        presenter.view = view

        model.presenter = presenter
        
        return view
    }
}
