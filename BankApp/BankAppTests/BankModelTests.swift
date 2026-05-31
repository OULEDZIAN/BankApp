//
//  BankModelTests.swift
//  BankAppTests
//
//  Created by AOZ on 31/05/2026.
//

import Foundation
import Testing
@testable import BankApp

@Suite("Bank Model")
struct BankModelTests {

    @Suite("Bank.isCreditAgricole")
    struct IsCreditAgricole {
        @Test func isCA1_returnsTrue() {
            let bank = Bank(name: "CA Test", isCA: 1, accounts: [])
            #expect(bank.isCreditAgricole)
        }

        @Test func isCA0_returnsFalse() {
            let bank = Bank(name: "BNP", isCA: 0, accounts: [])
            #expect(!bank.isCreditAgricole)
        }

        @Test func isCANegative_returnsFalse() {
            let bank = Bank(name: "Test", isCA: -1, accounts: [])
            #expect(!bank.isCreditAgricole)
        }

        @Test func isCA2_returnsFalse() {
            let bank = Bank(name: "Test", isCA: 2, accounts: [])
            #expect(!bank.isCreditAgricole)
        }
    }

    @Suite("BankOperation.timestamp")
    struct Timestamp {
        @Test func validUnixTimestamp_convertsToDate() {
            let operation = BankOperation(
                operationId: "1", title: "Test", amount: "0",
                category: "misc", date: "1644870724"
            )
            let expected = Date(timeIntervalSince1970: 1644870724)
            #expect(operation.timestamp == expected)
        }

        @Test func zeroTimestamp_returnsEpoch() {
            let operation = BankOperation(
                operationId: "1", title: "Test", amount: "0",
                category: "misc", date: "0"
            )
            #expect(operation.timestamp == Date(timeIntervalSince1970: 0))
        }

        @Test func invalidDateString_returnsEpoch() {
            let operation = BankOperation(
                operationId: "1", title: "Test", amount: "0",
                category: "misc", date: "invalid"
            )
            #expect(operation.timestamp == Date(timeIntervalSince1970: 0))
        }
    }

    @Suite("BankOperation.formattedDate")
    struct FormattedDate {
        @Test func knownTimestamp_formatsCorrectly() {
            let operation = BankOperation(
                operationId: "1", title: "Test", amount: "0",
                category: "misc", date: "1644870724"
            )
            #expect(operation.formattedDate == "14/02/2022")
        }
    }

    @Suite("Account.sortedOperations — RG05")
    struct SortedOperations {
        private func makeAccount(operations: [BankOperation]) -> Account {
            Account(
                order: 1, id: "1", holder: "H", role: 1,
                contractNumber: "C", label: "Test",
                productCode: "P", balance: 0, operations: operations
            )
        }

        private func makeBankOperation(
            id: String = "1",
            title: String = "Op",
            date: String = "1644870724"
        ) -> BankOperation {
            BankOperation(operationId: id, title: title, amount: "0", category: "misc", date: date)
        }

        @Test func operationsSortedByDateDescending() {
            let ops = [
                makeBankOperation(id: "1", title: "Oldest", date: "1000000000"),
                makeBankOperation(id: "2", title: "Newest", date: "1700000000"),
                makeBankOperation(id: "3", title: "Middle", date: "1400000000")
            ]
            let account = makeAccount(operations: ops)

            let titles = account.sortedOperations.map(\.title)
            #expect(titles == ["Newest", "Middle", "Oldest"])
        }

        @Test func alreadySortedDescending_remainsUnchanged() {
            let ops = [
                makeBankOperation(id: "1", title: "First", date: "1700000000"),
                makeBankOperation(id: "2", title: "Second", date: "1400000000"),
                makeBankOperation(id: "3", title: "Third", date: "1000000000")
            ]
            let account = makeAccount(operations: ops)

            let titles = account.sortedOperations.map(\.title)
            #expect(titles == ["First", "Second", "Third"])
        }

        @Test func sortedAscending_getsReversed() {
            let ops = [
                makeBankOperation(id: "1", title: "Old", date: "1000000000"),
                makeBankOperation(id: "2", title: "New", date: "1700000000")
            ]
            let account = makeAccount(operations: ops)

            #expect(account.sortedOperations[0].title == "New")
            #expect(account.sortedOperations[1].title == "Old")
        }

        @Test func emptyOperations_returnsEmpty() {
            let account = makeAccount(operations: [])
            #expect(account.sortedOperations.isEmpty)
        }

        @Test func singleOperation_returnsSingle() {
            let ops = [makeBankOperation(id: "1", title: "Only")]
            let account = makeAccount(operations: ops)

            #expect(account.sortedOperations.count == 1)
            #expect(account.sortedOperations[0].title == "Only")
        }

        @Test func operationCount_matchesInput() {
            let ops = (1...10).map { idx in
                makeBankOperation(id: "\(idx)", title: "Op\(idx)", date: "\(1000000000 + idx)")
            }
            let account = makeAccount(operations: ops)

            #expect(account.sortedOperations.count == 10)
        }
    }

    @Suite("Account.isNegativeBalance")
    struct IsNegativeBalance {
        private func makeAccount(balance: Double) -> Account {
            Account(
                order: 1, id: "1", holder: "H", role: 1,
                contractNumber: "C", label: "Test",
                productCode: "P", balance: balance, operations: []
            )
        }

        @Test func negativeBalance_returnsTrue() {
            #expect(makeAccount(balance: -150.30).isNegativeBalance)
        }

        @Test func positiveBalance_returnsFalse() {
            #expect(!makeAccount(balance: 2031.84).isNegativeBalance)
        }

        @Test func zeroBalance_returnsFalse() {
            #expect(!makeAccount(balance: 0).isNegativeBalance)
        }
    }

    @Suite("BankOperation.isNegative")
    struct IsNegative {
        @Test func negativeAmount_returnsTrue() {
            let operation = BankOperation(
                operationId: "1", title: "Test", amount: "-15,99",
                category: "misc", date: "0"
            )
            #expect(operation.isNegative)
        }

        @Test func positiveAmount_returnsFalse() {
            let operation = BankOperation(
                operationId: "1", title: "Test", amount: "100,00",
                category: "misc", date: "0"
            )
            #expect(!operation.isNegative)
        }

        @Test func zeroAmount_returnsFalse() {
            let operation = BankOperation(
                operationId: "1", title: "Test", amount: "0",
                category: "misc", date: "0"
            )
            #expect(!operation.isNegative)
        }
    }
}
