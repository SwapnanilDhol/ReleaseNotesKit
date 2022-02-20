//
//  ReleaseNotesView.swift
//  
//
//  Created by Swapnanil Dhol on 20/02/22.
//

import SwiftUI

@available(iOS 13, *)
public struct ReleaseNotesView: View {

    let itunesLookupResult: ITunesLookupResult
    private let dateFormatter = DateFormatter()

    public var body: some View {
        NavigationView {
            VStack(alignment: .leading) {
                VStack(alignment: .leading) {
                    Text("Version: \(itunesLookupResult.currentVersion ?? "")")
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.leading)
                        .font(.subheadline)
                    Text("Released on \(releaseDateString)")
                        .foregroundColor(.secondary)
                        .font(.subheadline)
                        .multilineTextAlignment(.leading)
                }
                .padding(.bottom)
                Divider()
                    .padding(.bottom)
                ScrollView {
                    Text(itunesLookupResult.releaseNotes ?? "")
                        .font(.headline)
                }
                Button(action:{
                    UIApplication.topViewController()?.dismiss(animated: true)
                }) {
                    RoundedRectangle(cornerRadius: 10)
                        .frame(height: 55)
                        .overlay(
                            Text("Dismiss")
                                .font(.headline)
                                .fontWeight(.bold)
                                .foregroundColor(.white),
                            alignment: .center
                        )
                }
            }.padding()
                .navigationBarTitle(Text("What's New"))
        }
    }

    private var releaseDateString: String {
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        guard let date = dateFormatter.date(from: itunesLookupResult.currentVersionReleaseDate ?? "") else {
            return ""
        }
        dateFormatter.dateFormat = "EEEE, MMM d, yyyy"
        return dateFormatter.string(from: date)
    }
}
