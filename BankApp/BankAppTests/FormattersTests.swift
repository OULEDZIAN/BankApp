//
//  FormattersTests.swift
//  BankAppTests
//
//  Created by AOZ on 29/05/2026.
//

import Foundation
import Testing
@testable import BankApp

@Suite("Formatters")
struct FormattersTests {
    @Suite("String → Currency")
    struct StringCurrency {
        @Test func negativeAmount() {
            #expect("-15,99".formattedAsCurrency == "-15,99 €")
        }

        @Test func positiveAmount() {
            #expect("2500,00".formattedAsCurrency == "2 500,00 €")
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

        @Test func negativeBalance() {
            #expect((-150.30).formattedAsCurrency == "-150,30 €")
        }

        @Test func zeroBalance() {
            #expect(0.0.formattedAsCurrency == "0,00 €")
        }

        @Test func smallBalance() {
            #expect(45.84.formattedAsCurrency == "45,84 €")
        }
    }

    @Suite("DateFormatter.dateFR")
    struct DateFormat {
        @Test func formatsDateInFrenchLocale() {
            let date = Date(timeIntervalSince1970: 1644870724)
            let result = DateFormatter.dateFR.string(from: date)
            #expect(result == "14/02/2022")
        }
    }
}
