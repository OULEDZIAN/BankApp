//
//  FormattersTests.swift
//  BankAppTests
//
//  Created by AOZ on 29/05/2026.
//

import Testing
@testable import BankApp

struct FormattersTests {
    @Test func stringFormattedAsCurrency_negativeAmount() {
        #expect("-15,99".formattedAsCurrency == "-15,99 €")
    }

    @Test func stringFormattedAsCurrency_largeAmount() {
        #expect("-750,00".formattedAsCurrency == "-750,00 €")
    }

    @Test func doubleFormattedAsCurrency_positiveBalance() {
        #expect(2031.84.formattedAsCurrency == "2 031,84 €")
    }

    @Test func doubleFormattedAsCurrency_smallBalance() {
        #expect(45.84.formattedAsCurrency == "45,84 €")
    }

    @Test func stringFormattedAsCurrency_invalidString() {
        #expect("invalid".formattedAsCurrency == "invalid")
    }
}
