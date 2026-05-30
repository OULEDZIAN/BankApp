//
//  FormattersTests.swift
//  BankAppTests
//
//  Created by AOZ on 29/05/2026.
//

import Testing
@testable import BankApp

@Suite("Formatters")
struct FormattersTests {
    @Suite("String → Currency")
    struct StringCurrency {
        @Test func negativeAmount() {
            #expect("-15,99".formattedAsCurrency == "-15,99 €")
        }

        @Test func largeAmount() {
            #expect("-750,00".formattedAsCurrency == "-750,00 €")
        }

        @Test func invalidString() {
            #expect("invalid".formattedAsCurrency == "invalid")
        }
    }

    @Suite("Double → Currency")
    struct DoubleCurrency {
        @Test func positiveBalance() {
            #expect(2031.84.formattedAsCurrency == "2 031,84 €")
        }

        @Test func smallBalance() {
            #expect(45.84.formattedAsCurrency == "45,84 €")
        }
    }
}
