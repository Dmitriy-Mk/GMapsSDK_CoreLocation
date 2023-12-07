//
//  PlacesViewController.swift
//  GoogleSDK
//
//  Created by Dmitriy Mkrtumyan on 30.11.23.
//

import UIKit
import GooglePlaces

protocol PassLikelyPlace: AnyObject {
    func passingSelectedPlace(_ place: GMSPlace)
}

class PlacesViewController: UIViewController {

    //MARK: - Data
    var likelyPlaces: [GMSPlace] = []
    let cellReuseID = "placesCell"
    var dataPassingDelegate: PassLikelyPlace?
    
    //MARK: - UI objects and setups
    private let placesTable = UITableView()
    
    private func setupPlacesTableView() {
        placesTable.delegate = self
        placesTable.dataSource = self
        
        placesTable.register(UITableViewCell.self, forCellReuseIdentifier: cellReuseID)
        placesTable.estimatedRowHeight = 20
        placesTable.rowHeight = 50
        placesTable.allowsSelection = true
        placesTable.allowsMultipleSelection = false
        placesTable.translatesAutoresizingMaskIntoConstraints = false
        placesTable.isScrollEnabled = false
        
        view.addSubview(placesTable)
        
        NSLayoutConstraint.activate([
            placesTable.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            placesTable.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            placesTable.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            placesTable.trailingAnchor.constraint(equalTo: view.trailingAnchor),
        ])
    }
    
    //MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        title = "Most Liked Places"
        placesTable.backgroundColor = .white
        setupPlacesTableView()
    }
}

extension PlacesViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        likelyPlaces.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellReuseID, for: indexPath)
        let item = likelyPlaces[indexPath.row]
        
        cell.textLabel?.text = item.name
        cell.backgroundColor = .white
        return cell
    }
}

extension PlacesViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        dataPassingDelegate?.passingSelectedPlace(likelyPlaces[indexPath.row])
        navigationController?.popViewController(animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        placesTable.frame.size.height / 5
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if (section == tableView.numberOfSections - 1) {
            return 1
        }
        return 0
    }
}
