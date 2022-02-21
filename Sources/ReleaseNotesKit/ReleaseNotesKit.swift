/*****************************************************************************
 * ReleaseNotesKit.swift
 * ReleaseNotesKit
 *****************************************************************************
 * Authors: Swapnanil Dhol <swapnanildhol # gmail.com>
 *
 * Refer to the COPYING file of the official project for license.
 *****************************************************************************/

import SwiftUI
import UIKit

public final class ReleaseNotesKit {

    public static let shared = ReleaseNotesKit()
    private var appID: String?
    private init() { }

    // MARK: - Configuration

    public func setApp(with appID: String) {
        self.appID = appID
        // Prepares data for App ID
        parseCacheOrFetchNewData { _ in }
    }

    // MARK: - Data Fetchers

    /// Attempts to parse cached data. If cached data is unavailable, it fetches new data.
    /// This method is kept public if you'd want to access just the lookup data without presenting it in a sheet view.
    /// - Parameter completion: ResultType: Success: ItunesLookupResult, Error: ReleaseNotesError
    public func parseCacheOrFetchNewData(
        precondition: Bool = true,
        completion: @escaping(Result<ITunesLookupResult, ReleaseNotesError>) -> Void
    ) {
        //First, checking if there's any cached data
        guard let cachedLookupData = UserDefaults.standard.data(forKey: "cachedLookupData") else {
            // If there is no cache, we fetch from ITunesSearchAPI
            fetchReleaseNotes { result in completion(result) }
            return
        }
        //Cache is found. Trying to parse into ITunesLookup model.
        guard let response = try? JSONDecoder().decode(ITunesLookup.self, from: cachedLookupData),
              let result = response.results.first else {
                  //If parsing fails, or if the results were none in the cache, we fetch again.
                  fetchReleaseNotes { result in completion(result) }
                  return
              }
        if !precondition {
            // If there was no preconditon for fetch, we return this cached result
            completion(.success(result))
        } else {
            // If there was a preconditon, we check the preconditions.
            // 1) Current version stored in the cached response != The installed app's version
            // 2) The cached lookup's appID is different than the set app ID.
            if result.currentVersion != Bundle.main.releaseVersionNumber ||
                String(result.appID ?? 0) != self.appID {
                fetchReleaseNotes { result in completion(result) }
            } else {
                completion(.success(result))
            }
        }
    }

    /// Fetches ITunes lookup for the provided app ID when it's not available in cache.
    /// This should not be called from anywhere except from `parseCacheOrFetchNewData`.
    /// ITunes API is rate limited by IP and so accessing from cache should our first priority.
    /// - Parameter completion: ResultType: Success: ItunesLookupResult, Error: ReleaseNotesError
    private func fetchReleaseNotes(
        completion: @escaping(Result<ITunesLookupResult, ReleaseNotesError>) -> Void
    ) {
        guard let appID = appID else {
            assertionFailure("\(#file): App ID is nil. Please configure by calling setApp(with appID) before accessing this singelton's methods.")
            return
        }
        var urlComponents = URLComponents()
        urlComponents.scheme = "https"
        urlComponents.host = "itunes.apple.com"
        urlComponents.path = "/lookup"
        urlComponents.queryItems = [
            URLQueryItem(name: "id", value: appID)
        ]
        guard let url = urlComponents.url else {
            completion(.failure(.malformedURL))
            return
        }
        URLSession.shared.dataTask(with: url) { data, _, _ in
            guard let data = data else {
                completion(.failure(.malformedData))
                return
            }
            UserDefaults.standard.set(data, forKey: "cachedLookupData")
            guard let response = try? JSONDecoder().decode(ITunesLookup.self, from: data) else {
                completion(.failure(.parsingFailure))
                return
            }
            guard let result = response.results.first else {
                completion(.failure(.noResults))
                return
            }
            completion(.success(result))
        }.resume()
    }
}
