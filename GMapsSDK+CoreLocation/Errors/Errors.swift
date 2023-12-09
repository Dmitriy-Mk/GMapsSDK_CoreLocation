//
//  Errors.swift
//  GMapsSDK+CoreLocation
//
//  Created by Dmitriy Mkrtumyan on 09.12.23.
//

import Foundation

enum URLError: Error {
    case urlGetError
}

enum ReverseGeocodingError: Error {
    case errorWhenReverseLocation
}
