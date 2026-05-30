//
//  LoadingState.swift
//  BankApp
//
//  Created by AOZ on 30/05/2026.
//

import Foundation

/// Represents the lifecycle of an async data fetch.
enum LoadingState: Sendable {
    case idle
    case loading
    case loaded([Bank])
    case error(BankError)
}
