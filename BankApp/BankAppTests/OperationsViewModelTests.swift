//
//  OperationsViewModelTests.swift
//  BankAppTests
//
//  Created by AOZ on 31/05/2026.
//

import Testing
@testable import BankApp

@Suite("OperationsViewModel")
struct OperationsViewModelTests {

    private func makeAccount(
        label: String = "Test",
        balance: Double = 0,
        operations: [BankOperation] = []
    ) -> Account {
        Account(
            order: 1, id: "1", holder: "H", role: 1,
            contractNumber: "C", label: label,
            productCode: "P", balance: balance, operations: operations
        )
    }

    @Suite("Delegation")
    struct Delegation {
        @Test func sortedOperations_delegatesToAccount() {
            let ops = [
                BankOperation(operationId: "1", title: "Old", amount: "0", category: "misc", date: "1000000000"),
                BankOperation(operationId: "2", title: "New", amount: "0", category: "misc", date: "1700000000")
            ]
            let account = Account(
                order: 1, id: "1", holder: "H", role: 1,
                contractNumber: "C", label: "Test",
                productCode: "P", balance: 0, operations: ops
            )
            let viewModel = OperationsViewModel(account: account)

            let vmTitles = viewModel.sortedOperations.map(\.title)
            let accountTitles = account.sortedOperations.map(\.title)
            #expect(vmTitles == accountTitles)
        }
    }

    @Suite("Account properties")
    struct AccountProperties {
        @Test func accountLabel_matchesAccount() {
            let account = Account(
                order: 2, id: "42", holder: "Jean", role: 1,
                contractNumber: "CT999", label: "Compte joint",
                productCode: "CJ", balance: 843.15, operations: []
            )
            let viewModel = OperationsViewModel(account: account)

            #expect(viewModel.accountLabel == "Compte joint")
        }

        @Test func formattedBalance_matchesAccount() {
            let account = Account(
                order: 1, id: "1", holder: "H", role: 1,
                contractNumber: "C", label: "Test",
                productCode: "P", balance: 843.15, operations: []
            )
            let viewModel = OperationsViewModel(account: account)

            #expect(viewModel.formattedBalance == "843,15 \u{20AC}")
        }

        @Test func positiveBalance_isNotNegative() {
            let account = Account(
                order: 1, id: "1", holder: "H", role: 1,
                contractNumber: "C", label: "Test",
                productCode: "P", balance: 100, operations: []
            )
            let viewModel = OperationsViewModel(account: account)

            #expect(!viewModel.isNegativeBalance)
        }

        @Test func negativeBalance_isNegative() {
            let account = Account(
                order: 1, id: "1", holder: "H", role: 1,
                contractNumber: "C", label: "Test",
                productCode: "P", balance: -50, operations: []
            )
            let viewModel = OperationsViewModel(account: account)

            #expect(viewModel.isNegativeBalance)
        }
    }
}
