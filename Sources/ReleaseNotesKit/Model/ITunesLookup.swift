//
//  ITunesLookup.swift
//  
//
//  Created by Swapnanil Dhol on 20/02/22.
//

import Foundation

public struct ITunesLookup: Codable {
    public let resultCount: Int
    public let results: [ITunesLookupResult]
}

public struct ITunesLookupResult: Codable {
    public let appIconURL: String?
    public let appName: String?
    public let appURL: String?
    public let appDescription: String?
    public let sellerName: String?
    public let minimumOSVersion: String?
    public let currentVersion: String?
    public let currentVersionReleaseDate: String?
    public let releaseNotes: String?

    enum CodingKeys: String, CodingKey {
        case appIconURL = "artworkUrl60"
        case appName = "trackCensoredName"
        case appURL = "artistViewUrl"
        case minimumOSVersion = "minimumOsVersion"
        case appDescription = "description"
        case currentVersion = "version"
        case currentVersionReleaseDate
        case sellerName
        case releaseNotes
    }
}

