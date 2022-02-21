/*****************************************************************************
 * ReleaseNotesKit+.swift
 * ReleaseNotesKit
 *****************************************************************************
 * Authors: Swapnanil Dhol <swapnanildhol # gmail.com>
 *
 * Refer to the COPYING file of the official project for license.
 *****************************************************************************/

import SwiftUI
import UIKit

// MARK: - Presentors
@available(iOS 13, *)
extension ReleaseNotesKit {

    /// Presents the Release Notes sheet when
    ///  1) The current app's version number doesn't match the version number of the data stored in cache.
    ///  2) When there is no value in the `lastVersionSheetShownFor` key in UserDefaults.
    public func presentReleaseNotesViewOnVersionChange() {
        guard let lastVersionSheetShownFor = UserDefaults.standard.string(forKey: "lastVersionSheetShownFor"),
              lastVersionSheetShownFor == Bundle.main.releaseVersionNumber else {
                  presentReleaseNotesView(precondition: true)
                  return
              }
    }

    /// Presents ReleaseNotesView without any preconditions.
    /// - Parameter controller: The controller on which the sheet should be presented. If none is provided, it uses the top view controller.
    public func presentReleaseNotesView(precondition: Bool = false, in controller: UIViewController? = nil) {
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
                    let releaseNotesView = ReleaseNotesView(
                        currentVersion: lookup.currentVersion ?? "",
                        releaseDateString: lookup.currentVersionReleaseDate ?? "",
                        releaseNotes: lookup.releaseNotes ?? ""
                    )
                    let hostingController = UIHostingController(rootView: releaseNotesView)
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
