//
//  Bank.swift
//  BankApp
//
//  Created by AOZ on 28/05/2026.
//

import Foundation

// MARK: - Root Response

struct BankResponse: Codable {
    let banks: [Bank]
}

// MARK: - Bank

struct Bank: Codable, Identifiable {
    let name: String
    let isCA: Int
    let accounts: [Account]

    var id: String { name }

    /// Indicates whether this bank belongs to the Crédit Agricole group
    var isCreditAgricole: Bool { isCA == 1 }
}

// MARK: - Account

struct Account: Codable, Identifiable {
    let order: Int
    let id: String
    let holder: String
    let role: Int
    let contractNumber: String
    let label: String
    let productCode: String
    let balance: Double
    let operations: [Operation]

    enum CodingKeys: String, CodingKey {
        case order, id, holder, role
        case contractNumber = "contract_number"
        case label
        case productCode = "product_code"
        case balance, operations
    }

    var formattedBalance: String {
        balance.formattedAsCurrency
    }
}

// MARK: - Operation

struct Operation: Codable, Identifiable {
    let id: String
    let title: String
    let amount: String
    let category: String
    let date: String

    /// Converts the raw Unix timestamp string into a Swift Date
    var timestamp: Date {
        let interval = TimeInterval(date) ?? 0
        return Date(timeIntervalSince1970: interval)
    }

    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/yyyy"
        formatter.locale = Locale(identifier: "fr_FR")
        return formatter.string(from: timestamp)
    }

    var formattedAmount: String {
        amount.formattedAsCurrency
    }

    var isNegative: Bool {
        amount.hasPrefix("-")
    }
}
