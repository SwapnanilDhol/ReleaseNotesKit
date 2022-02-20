import SwiftUI
import UIKit

public enum ReleaseNotesError: String, Error {
    case malFormedURL
    case malformedData
    case parsingFailure
    case noResults
}

public final class ReleaseNotesKit {

    public static let shared = ReleaseNotesKit()
    private var appID: String?
    private init() { }

    // MARK: - Configuration

    public func setApp(with appID: String) {
        self.appID = appID
        parseCacheOrFetchNewData { _ in }
    }

    // MARK: - Data Fetchers

    /// Attempts to parse cached data. If cached data is unavailable, it fetches new data.
    /// This method is kept public if you'd want to access just the lookup data without presenting it in a sheet view.
    /// - Parameter completion: ResultType: Success: ItunesLookupResult, Error: ReleaseNotesError
    public func parseCacheOrFetchNewData(precondition: Bool = true, completion: @escaping(Result<ITunesLookupResult, ReleaseNotesError>) -> Void) {
        guard let cachedLookupData = UserDefaults.standard.data(forKey: "cachedLookupData") else {
            fetchReleaseNotes { result in completion(result) }
            return
        }
        guard let response = try? JSONDecoder().decode(ITunesLookup.self, from: cachedLookupData),
              let result = response.results.first else {
                  fetchReleaseNotes { result in completion(result) }
            return
        }
        if !precondition {
            print("Fetched Result from cache")
            completion(.success(result))
        } else {
            if result.currentVersion != Bundle.main.releaseVersionNumber {
                fetchReleaseNotes { result in completion(result) }
            } else {
                print("Fetched Result from cache")
                completion(.success(result))
            }
        }
    }

    /// Fetches ITunes lookup for the provided app ID when it's not available in cache.
    /// This should not be called from anywhere except from `parseCacheOrFetchNewData`.
    /// ITunes API is rate limited by IP and so accessing from cache should our first priority.
    /// - Parameter completion: ResultType: Success: ItunesLookupResult, Error: ReleaseNotesError
    private func fetchReleaseNotes(completion: @escaping(Result<ITunesLookupResult, ReleaseNotesError>) -> Void) {
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
            completion(.failure(.malFormedURL))
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

// MARK: - Presentors
@available(iOS 13, *)
extension ReleaseNotesKit {

    /// Presents the Release Notes sheet when
    ///  1) The current app's version number doesn't match the version number of the data stored in cache.
    ///  2) When there is no value in the `lastVersionSheetShownFor` key in UserDefaults.
    public func presentReleaseNotesForTheFirstTime() {
        guard let lastVersionSheetShownFor = UserDefaults.standard.string(forKey: "lastVersionSheetShownFor") else {
            presentWhatsNew(precondition: true, in: UIApplication.topViewController())
            return
        }
        if lastVersionSheetShownFor != Bundle.main.releaseVersionNumber {
            presentWhatsNew(precondition: true, in: UIApplication.topViewController())
        }
    }

    /// Presents ReleaseNotesView without any preconditions.
    /// - Parameter controller: The controller on which the sheet should be presented. If none is provided, it uses the top view controller.
    public func presentWhatsNew(precondition: Bool = false, in controller: UIViewController?) {
        parseCacheOrFetchNewData(precondition: precondition) { result in
            switch result {
            case .success(let lookup):
                if precondition {
                    guard lookup.currentVersion == Bundle.main.releaseVersionNumber else {
                        //Here, we check if the response's version is the same as our app's installed version.
                        //It might happen that the current installed version isn't the same as the latest available version.
                        //Probably should ask the user to update the app.
                        //I should make "PleaseUpdateKit" :D
                        return
                    }
                }
                DispatchQueue.main.async {
                    let hostingController = UIHostingController(rootView: ReleaseNotesView(itunesLookupResult: lookup))
                    UserDefaults.standard.set(Bundle.main.releaseVersionNumber, forKey: "lastVersionSheetShownFor")
                    if let controller = controller {
                        controller.present(hostingController, animated: true)
                    } else {
                        UIApplication.topViewController()?.present(hostingController, animated: true)
                    }
                }
            case .failure(let error):
                assertionFailure(error.rawValue)
            }
        }
    }
}

extension Bundle {
    var releaseVersionNumber: String? {
        return infoDictionary?["CFBundleShortVersionString"] as? String
    }
    var buildVersionNumber: String? {
        return infoDictionary?["CFBundleVersion"] as? String
    }
}

extension UIApplication {
    class func topViewController(controller: UIViewController? = UIApplication.shared.windows.first { $0.isKeyWindow }?.rootViewController) -> UIViewController? {
        if let navigationController = controller as? UINavigationController {
            return topViewController(controller: navigationController.visibleViewController)
        }
        if let tabController = controller as? UITabBarController {
            if let selected = tabController.selectedViewController {
                return topViewController(controller: selected)
            }
        }
        if let presented = controller?.presentedViewController {
            return topViewController(controller: presented)
        }
        return controller
    }
}
