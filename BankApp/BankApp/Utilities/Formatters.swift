//
//  Formatters.swift
//  BankApp
//
//  Created by AOZ on 29/05/2026.
//

import Foundation

// MARK: - Shared Formatters

extension NumberFormatter {
    /// Reusable currency formatter for French locale — avoids recreating a formatter on every call.
    static let currencyFR: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = Locale(identifier: "fr_FR")
        return formatter
    }()
}

extension DateFormatter {
    static let dateFR: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/yyyy"
        formatter.locale = Locale(identifier: "fr_FR")
        return formatter
    }()

    static let dateLongFR: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.locale = Locale(identifier: "fr_FR")
        return formatter
    }()
}

// MARK: - Whitespace Normalization

private extension String {
    /// NumberFormatter with fr_FR locale uses non-breaking spaces (U+00A0, U+202F) as grouping separators.
    /// This normalizes them to regular spaces for predictable display and testability.
    var normalizedWhitespace: String {
        unicodeScalars
            .map { scalar in
                CharacterSet.whitespaces.contains(scalar) ? " " : String(scalar)
            }
            .joined()
    }
}

// MARK: - Double Currency Formatting

extension Double {
    /// Formats a numeric balance into French currency (e.g. 2031.84 → "2 031,84 €").
    var formattedAsCurrency: String {
        let result = NumberFormatter.currencyFR.string(
            from: NSNumber(value: self)
        ) ?? "\(self)"
        return result.normalizedWhitespace
    }
}

// MARK: - String Currency Formatting

extension String {
    /// Converts a French comma-separated amount string into currency (e.g. "-15,99" → "-15,99 €").
    /// Returns the original string unchanged if it cannot be parsed as a number.
    var formattedAsCurrency: String {
        let normalized = replacingOccurrences(of: ",", with: ".")
        guard let value = Double(normalized) else { return self }
        let result = NumberFormatter.currencyFR.string(
            from: NSNumber(value: value)
        ) ?? self
        return result.normalizedWhitespace
    }
}
