//
//  ServiceTests.swift
//  BankAppTests
//
//  Created by AOZ on 29/05/2026.
//

import Testing
@testable import BankApp

// MARK: - Mock Service

/// Configurable mock for testing any code that depends on BankServiceProtocol.
struct MockBankService: BankServiceProtocol {
    var result: Result<[Bank], BankError>

    func fetchBanks() async throws(BankError) -> [Bank] {
        switch result {
        case .success(let banks):
            return banks
        case .failure(let error):
            throw error
        }
    }
}

// MARK: - Tests

@Suite("BankService")
struct ServiceTests {
    @Test func successfulFetchReturnsNonEmptyArray() async throws {
        let mockBanks = [
            Bank(
                name: "Test Bank",
                isCA: 1,
                accounts: []
            )
        ]
        let service = MockBankService(result: .success(mockBanks))

        let banks = try await service.fetchBanks()

        #expect(!banks.isEmpty)
        #expect(banks[0].name == "Test Bank")
        #expect(banks[0].isCreditAgricole)
    }

    @Test func failedFetchThrowsBankError() async {
        let service = MockBankService(result: .failure(.networkUnavailable))

        await #expect(throws: BankError.networkUnavailable) {
            try await service.fetchBanks()
        }
    }
}
