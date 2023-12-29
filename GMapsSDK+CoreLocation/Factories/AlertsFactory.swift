//
//  AlertsFactory.swift
//  GMapsSDK+CoreLocation
//
//  Created by Dmitriy Mkrtumyan on 29.12.23.
//

import UIKit.UIView

enum AlertsTitles: String {
    case placesFailure = "Fetch Error"
}

enum AlertsMessages: String {
    case placesFetchError = "Unable to retrieve location from Google Places. Please check your connection, go back and try again."
}

enum AlertActionTitle: String {
    case ok = "OK"
}

protocol AlertsFactoryInterface: AnyObject {
    func showAlert(with type: AlertsTitles) -> UIViewController
}

final class AlertsFactory: AlertsFactoryInterface {
    
    func showAlert(with type: AlertsTitles) -> UIViewController {
        switch type {
        case .placesFailure: return setupOkAlert()
        }
    }
    
    private func setupOkAlert() -> UIViewController {
        
        let alertController = UIAlertController(title: AlertsTitles.placesFailure.rawValue, message: AlertsMessages.placesFetchError.rawValue, preferredStyle: .alert)
        let action = UIAlertAction(title: AlertActionTitle.ok.rawValue, style: .cancel)
        
        alertController.addAction(action)
        
        return alertController
    }
}
