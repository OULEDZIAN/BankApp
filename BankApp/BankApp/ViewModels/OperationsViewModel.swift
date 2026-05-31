//
//  OperationsViewModel.swift
//  BankApp
//
//  Created by AOZ on 31/05/2026.
//

import Foundation

@Observable
final class OperationsViewModel {
    private let account: Account

    var accountLabel: String { account.label }
    var formattedBalance: String { account.formattedBalance }
    var isNegativeBalance: Bool { account.isNegativeBalance }

    var sortedOperations: [BankOperation] {
        account.sortedOperations
    }

    init(account: Account) {
        self.account = account
    }
}
