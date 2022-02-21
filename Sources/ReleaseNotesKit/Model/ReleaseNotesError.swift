/*****************************************************************************
 * ReleaseNotesError.swift
 * ReleaseNotesKit
 *****************************************************************************
 * Authors: Swapnanil Dhol <swapnanildhol # gmail.com>
 *
 * Refer to the COPYING file of the official project for license.
 *****************************************************************************/

import Foundation

public enum ReleaseNotesError: String, Error {
    case malformedURL
    case malformedData
    case parsingFailure
    case noResults
}
