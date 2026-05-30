//
//  Bank.swift
//  BankApp
//
//  Created by AOZ on 28/05/2026.
//

import Foundation

// MARK: - Bank

struct Bank: Codable, Identifiable {
    let name: String
    let isCA: Int
    let accounts: [Account]

    var id: String { name }

    /// Indicates whether this bank belongs to the Crédit Agricole group
    var isCreditAgricole: Bool { isCA == 1 }

    var sortedAccounts: [Account] {
        accounts.sorted { $0.order < $1.order }
    }
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
    let id: UUID
    let operationId: String
    let title: String
    let amount: String
    let category: String
    let date: String

    enum CodingKeys: String, CodingKey {
        case operationId = "id"
        case title, amount, category, date
    }

    init(
        operationId: String,
        title: String,
        amount: String,
        category: String,
        date: String
    ) {
        self.id = UUID()
        self.operationId = operationId
        self.title = title
        self.amount = amount
        self.category = category
        self.date = date
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = UUID()
        self.operationId = try container.decode(String.self, forKey: .operationId)
        self.title = try container.decode(String.self, forKey: .title)
        self.amount = try container.decode(String.self, forKey: .amount)
        self.category = try container.decode(String.self, forKey: .category)
        self.date = try container.decode(String.self, forKey: .date)
    }

    /// Converts the raw Unix timestamp string into a Swift Date
    var timestamp: Date {
        let interval = TimeInterval(date) ?? 0
        return Date(timeIntervalSince1970: interval)
    }

    var formattedDate: String {
        DateFormatter.dateFR.string(from: timestamp)
    }

    var formattedAmount: String {
        amount.formattedAsCurrency
    }

    var isNegative: Bool {
        amount.hasPrefix("-")
    }
}
