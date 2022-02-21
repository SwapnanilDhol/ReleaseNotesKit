/*****************************************************************************
 * ReleaseNotesView.swift
 * ReleaseNotesKit
 *****************************************************************************
 * Authors: Swapnanil Dhol <swapnanildhol # gmail.com>
 *
 * Refer to the COPYING file of the official project for license.
 *****************************************************************************/

import SwiftUI

@available(iOS 13, *)
public struct ReleaseNotesView: View {

    private let title: String
    private let currentVersion: String
    private let releaseDateString: String
    private let releaseNotes: String
    private let topController: UIViewController?
    private let dismissButtonTitle: String
    private let dismissButtonColor: Color
    private let dateFormatter = DateFormatter()

    // MARK: - Init

    public init(
        title: String = "What's New",
        currentVersion: String = Bundle.main.releaseVersionNumber ?? "",
        releaseDateString: String,
        releaseNotes: String,
        topController: UIViewController? = UIApplication.topViewController(),
        dismissButtonTitle: String = "Dismiss",
        dismissButtonColor: Color = .blue
    ) {
        self.title = title
        self.currentVersion = currentVersion
        self.releaseDateString = releaseDateString
        self.releaseNotes = releaseNotes
        self.topController = topController
        self.dismissButtonTitle = dismissButtonTitle
        self.dismissButtonColor = dismissButtonColor
    }

    // MARK: - View

    public var body: some View {
        NavigationView {
            VStack(alignment: .leading) {
                VStack(alignment: .leading) {
                    Text("Version: \(currentVersion)")
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.leading)
                        .font(.subheadline)
                    Text("Released on \(releaseDateFormattedString)")
                        .foregroundColor(.secondary)
                        .font(.subheadline)
                        .multilineTextAlignment(.leading)
                }
                .padding(.bottom)
                Divider()
                    .padding(.bottom)
                ScrollView {
                    Text(releaseNotes)
                        .font(.headline)
                }
                Button(action:{
                    topController?.dismiss(animated: true)
                }) {
                    RoundedRectangle(cornerRadius: 10)
                        .frame(height: 55)
                        .overlay(
                            Text(dismissButtonTitle)
                                .font(.headline)
                                .fontWeight(.bold)
                                .foregroundColor(.white),
                            alignment: .center
                        )
                }
            }.padding()
                .navigationBarTitle(Text(title))
        }
    }

    private var releaseDateFormattedString: String {
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        guard let date = dateFormatter.date(from: releaseDateString) else { return "" }
        dateFormatter.dateFormat = "EEEE, MMM d, yyyy"
        return dateFormatter.string(from: date)
    }
}
