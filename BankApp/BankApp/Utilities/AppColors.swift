//
//  AppColors.swift
//  BankApp
//
//  Created by AOZ on 28/05/2026.
//

import SwiftUI

// MARK: - App Color System

enum AppColors: String {
    // Brand
    case accentCA         = "AccentCA"
    case backgroundPrimary = "BackgroundPrimary"
    case backgroundCard   = "BackgroundCard"
    case amountNegative   = "AmountNegative"
}

extension AppColors {
    /// Type-safe SwiftUI Color from asset catalog
    var color: Color {
        Color(rawValue, bundle: .main)
    }
}

// MARK: - SwiftUI convenience

extension Color {
    static let caAccent          = AppColors.accentCA.color
    static let caBackgroundPrimary = AppColors.backgroundPrimary.color
    static let caBackgroundCard   = AppColors.backgroundCard.color
    static let caAmountNegative   = AppColors.amountNegative.color
}
