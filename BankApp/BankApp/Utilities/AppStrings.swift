//
//  AppStrings.swift
//  BankApp
//
//  Created by AOZ on 29/05/2026.
//

import Foundation

// MARK: - Type-safe localization keys

/// Centralizes all localized strings — SwiftLint blocks direct String(localized:) usage outside this file.
enum AppStrings {
    enum Error {
        static let networkUnavailable = String(localized: "error.networkUnavailable")
        static let decodingFailed = String(localized: "error.decodingFailed")
        static let pullToRefresh = String(localized: "error.pullToRefresh")
    }
    enum Section {
        static let creditAgricole = String(localized: "section.creditAgricole")
        static let otherBanks = String(localized: "section.otherBanks")
    }
    enum Accounts {
        static let title = String(localized: "accounts.title")
    }
}
