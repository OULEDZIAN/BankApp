//
//  BankServiceProtocol.swift
//  BankApp
//
//  Created by AOZ on 29/05/2026.
//

import Foundation

// MARK: - Service Protocol

/// Contract for fetching bank data — enables dependency injection and testability via MockBankService.
protocol BankServiceProtocol: Sendable {
    func fetchBanks() async throws(BankError) -> [Bank]
}

// MARK: - Service Errors

/// Typed errors thrown at service boundaries — localized descriptions come from AppStrings.
enum BankError: Error, LocalizedError {
    case networkUnavailable
    case decodingFailed

    var errorDescription: String? {
        switch self {
        case .networkUnavailable:
            AppStrings.Error.networkUnavailable
        case .decodingFailed:
            AppStrings.Error.decodingFailed
        }
    }
}
