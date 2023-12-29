//
//  Presenter.swift
//  GoogleSDK
//
//  Created by Dmitriy Mkrtumyan on 21.11.23.
//

import CoreLocation
import GoogleMaps

final class MapPresenter {
    private let apiKey = "AIzaSyD9AwH3h0wlVcrukukFuNhUJRpjLvaek7Q"
    weak var view: MapViewInput!
    var model: MapModelInput!
    var mapView: GMSMapView?
    
    init(model: MapModelInput) {
        self.model = model
    }
    
    private func showPath(polylineString: String, for map: GMSMapView) {
        let path = GMSPath(fromEncodedPath: polylineString)
        let polyline = GMSPolyline(path: path)
        
        polyline.strokeWidth = 5.0
        polyline.strokeColor = .systemBlue
        polyline.map = map
        
        DispatchQueue.main.async {
            if let path {
                let bounds = GMSCoordinateBounds(path: path)
                let cameraUpdate = GMSCameraUpdate.fit(bounds, withPadding: 50.0)
                
                map.animate(with: cameraUpdate)
            }
        }
    }
}

// MARK: - extensions
extension MapPresenter: MapViewOutput {
    func loadView() {
        model.setupMapView()
        if let mapView {
            view.loadMapView(mapView)
        }
    }
    
    func drawRoute(map: GMSMapView, destInfo: [String], origin: CLLocationCoordinate2D, destination: CLLocationCoordinate2D) throws {
        let config = URLSessionConfiguration.default
        let session = URLSession(configuration: config)
        let originString = "\(origin.latitude),\(origin.longitude)"
        let destinationString = "\(destination.latitude),\(destination.longitude)"
        guard let pathURL = URL(string: "https://maps.googleapis.com/maps/api/directions/json?origin=\(originString)&destination=\(destinationString)&mode=driving&key=\(apiKey)") else {
            let error = URLError.urlGetError
            print(error)
            throw error
        }
        
        let task = session.dataTask(with: pathURL) { data, response, error in
            guard error == nil else {
                if let error { print(error.localizedDescription) }
                return
            }
            guard let parsedData = data else { return }
            
            print(response ?? "Response is empty!")
            
            do {
                guard let jsonData: [String: Any] = try JSONSerialization.jsonObject(with: parsedData,
                                                                                     options: .fragmentsAllowed) as? [String: Any] else { return }
                guard let routes = jsonData["routes"] as? NSArray else {
                    print("Cant get routes!")
                    return
                }
                
                if routes.count > 0 {
                    let firstDictionary = routes[0] as? NSDictionary
                    let overview_polyline = firstDictionary?["overview_polyline"] as? NSDictionary
                    let points = overview_polyline?.object(forKey: "points") as? String
                    
                    DispatchQueue.main.async {
                        guard let legs = firstDictionary?["legs"] as? Array<Dictionary<String, AnyObject>> else {
                            print("Legs are note available!")
                            return
                        }
//                        let distance = legs[0]["distance"] as? NSDictionary
//                        let distanceValue = distance?["value"] as? Int ?? 0
                        
//                        let duration = legs[0]["duration"] as? NSDictionary
//                        let totalDurationInSeconds = duration?["value"] as? Int ?? 0

                        guard let points else { return }
                        self.showPath(polylineString: points, for: map)
                        
                        let startLocationDictionary = legs[0]["start_location"] as! Dictionary<String, AnyObject>
                        let originCoordinate = CLLocationCoordinate2DMake(startLocationDictionary["lat"] as! Double, startLocationDictionary["lng"] as! Double)
                        
                        let endLocationDictionary = legs[legs.count - 1]["end_location"] as! Dictionary<String, AnyObject>
                        let destinationCoordinate = CLLocationCoordinate2DMake(endLocationDictionary["lat"] as! Double, endLocationDictionary["lng"] as! Double)

                        let originMarker = GMSMarker()
                        originMarker.position = CLLocationCoordinate2D(latitude: originCoordinate.latitude,
                                                                       longitude: originCoordinate.longitude)
                        originMarker.map = map
                        
                        let destinationMarker = GMSMarker()
                        destinationMarker.position = CLLocationCoordinate2D(latitude: destinationCoordinate.latitude,
                                                                            longitude: destinationCoordinate.longitude)
                        destinationMarker.title = destInfo[0]
                        destinationMarker.snippet = destInfo[1]
                        destinationMarker.map = map
                    }
                } else {
                    print(routes.count)
                }
                
            } catch {
                print(error.localizedDescription)
            }
        }
        task.resume()
    }
}

extension MapPresenter: MapModelOutput {
    func completedMapView(_ mapView: GMSMapView) {
        self.mapView = mapView
    }
}
