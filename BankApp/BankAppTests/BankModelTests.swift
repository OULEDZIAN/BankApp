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

    @Suite("BankOperation.accessibilityDate")
    struct AccessibilityDate {
        @Test func knownTimestamp_formatsLongDate() {
            let operation = BankOperation(
                operationId: "1", title: "Test", amount: "0",
                category: "misc", date: "1644870724"
            )
            #expect(operation.accessibilityDate == "14 février 2022")
        }

        @Test func epochTimestamp_formatsLongDate() {
            let operation = BankOperation(
                operationId: "1", title: "Test", amount: "0",
                category: "misc", date: "0"
            )
            #expect(operation.accessibilityDate == "1 janvier 1970")
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

    @Suite("Account.sortedOperations — RG06 (same date, alphabetical tiebreak)")
    struct SortedOperationsRG06 {
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

        @Test func sameDateOperations_sortedAlphabetically() {
            let sameDate = "1644870724"
            let ops = [
                makeBankOperation(id: "1", title: "Netflix", date: sameDate),
                makeBankOperation(id: "2", title: "Amazon", date: sameDate),
                makeBankOperation(id: "3", title: "Carrefour", date: sameDate)
            ]
            let account = makeAccount(operations: ops)

            let titles = account.sortedOperations.map(\.title)
            #expect(titles == ["Amazon", "Carrefour", "Netflix"])
        }

        @Test func sameDateTwoOperations_alphabetical() {
            let sameDate = "1644870724"
            let ops = [
                makeBankOperation(id: "1", title: "Zara", date: sameDate),
                makeBankOperation(id: "2", title: "Auchan", date: sameDate)
            ]
            let account = makeAccount(operations: ops)

            #expect(account.sortedOperations[0].title == "Auchan")
            #expect(account.sortedOperations[1].title == "Zara")
        }

        @Test func sameDateAlreadyAlphabetical_remainsUnchanged() {
            let sameDate = "1644870724"
            let ops = [
                makeBankOperation(id: "1", title: "Alpha", date: sameDate),
                makeBankOperation(id: "2", title: "Beta", date: sameDate)
            ]
            let account = makeAccount(operations: ops)

            let titles = account.sortedOperations.map(\.title)
            #expect(titles == ["Alpha", "Beta"])
        }

        @Test func mixedDatesAndSameDates_sortedCorrectly() {
            let ops = [
                makeBankOperation(id: "1", title: "Netflix", date: "1644870724"),
                makeBankOperation(id: "2", title: "Amazon", date: "1644870724"),
                makeBankOperation(id: "3", title: "Loyer", date: "1644611558"),
                makeBankOperation(id: "4", title: "Salaire", date: "1700000000")
            ]
            let account = makeAccount(operations: ops)

            let titles = account.sortedOperations.map(\.title)
            #expect(titles == ["Salaire", "Amazon", "Netflix", "Loyer"])
        }

        @Test func threeDatesWithTiesOnEach_sortedCorrectly() {
            let ops = [
                makeBankOperation(id: "1", title: "C", date: "1000000000"),
                makeBankOperation(id: "2", title: "A", date: "1000000000"),
                makeBankOperation(id: "3", title: "Z", date: "2000000000"),
                makeBankOperation(id: "4", title: "M", date: "2000000000"),
                makeBankOperation(id: "5", title: "B", date: "1500000000")
            ]
            let account = makeAccount(operations: ops)

            let titles = account.sortedOperations.map(\.title)
            #expect(titles == ["M", "Z", "B", "A", "C"])
        }

        @Test func allSameDate_allSortedByTitle() {
            let date = "1644870724"
            let ops = (1...5).map { idx in
                makeBankOperation(id: "\(idx)", title: "Op\(6 - idx)", date: date)
            }
            let account = makeAccount(operations: ops)

            let titles = account.sortedOperations.map(\.title)
            #expect(titles == ["Op1", "Op2", "Op3", "Op4", "Op5"])
        }

        @Test func singleOperationSameDate_returnsSingle() {
            let ops = [makeBankOperation(id: "1", title: "Only", date: "1644870724")]
            let account = makeAccount(operations: ops)

            #expect(account.sortedOperations.count == 1)
            #expect(account.sortedOperations[0].title == "Only")
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

    @Suite("BankOperation.accessibilityAmount")
    struct AccessibilityAmount {
        @Test func negativeAmount_prefixedWithMoins() {
            let operation = BankOperation(
                operationId: "1", title: "Test", amount: "-53,00",
                category: "misc", date: "0"
            )
            #expect(operation.accessibilityAmount == "moins 53,00 €")
        }

        @Test func positiveAmount_unchangedFromFormatted() {
            let operation = BankOperation(
                operationId: "1", title: "Test", amount: "2500,00",
                category: "misc", date: "0"
            )
            #expect(operation.accessibilityAmount == operation.formattedAmount)
        }

        @Test func zeroAmount_unchangedFromFormatted() {
            let operation = BankOperation(
                operationId: "1", title: "Test", amount: "0",
                category: "misc", date: "0"
            )
            #expect(operation.accessibilityAmount == operation.formattedAmount)
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
