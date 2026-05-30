//
//  AccountsViewModelTests.swift
//  BankAppTests
//
//  Created by AOZ on 30/05/2026.
//

import Testing
@testable import BankApp

struct AccountsViewModelTests {
    private let mockBanks = [
        Bank(name: "Crédit Agricole Centre", isCA: 1, accounts: []),
        Bank(name: "Crédit Agricole Sud", isCA: 1, accounts: []),
        Bank(name: "BNP Paribas", isCA: 0, accounts: [])
    ]

    @MainActor @Test func creditAgricoleBanks_returnsOnlyCABanks() async {
        let service = MockBankService(result: .success(mockBanks))
        let viewModel = AccountsViewModel(service: service)

        await viewModel.fetchBanks()

        #expect(viewModel.creditAgricoleBanks.count == 2)
        #expect(viewModel.creditAgricoleBanks.allSatisfy { $0.isCreditAgricole })
    }

    @MainActor @Test func otherBanks_returnsOnlyNonCABanks() async {
        let service = MockBankService(result: .success(mockBanks))
        let viewModel = AccountsViewModel(service: service)

        await viewModel.fetchBanks()

        #expect(viewModel.otherBanks.count == 1)
        #expect(viewModel.otherBanks.allSatisfy { !$0.isCreditAgricole })
    }

    @MainActor @Test func fetchBanks_setsStateToLoaded() async {
        let service = MockBankService(result: .success(mockBanks))
        let viewModel = AccountsViewModel(service: service)

        await viewModel.fetchBanks()

        guard case .loaded(let banks) = viewModel.state else {
            Issue.record("Expected .loaded state, got \(viewModel.state)")
            return
        }
        #expect(banks.count == 3)
    }

    @MainActor @Test func fetchBanks_setsStateToError() async {
        let service = MockBankService(result: .failure(.networkUnavailable))
        let viewModel = AccountsViewModel(service: service)

        await viewModel.fetchBanks()

        guard case .error = viewModel.state else {
            Issue.record("Expected .error state, got \(viewModel.state)")
            return
        }
    }

    @MainActor @Test func creditAgricoleBanks_emptyBeforeFetch() {
        let service = MockBankService(result: .success(mockBanks))
        let viewModel = AccountsViewModel(service: service)

        #expect(viewModel.creditAgricoleBanks.isEmpty)
    }

    @MainActor @Test func fetchBanks_withEmptyResponse() async {
        let service = MockBankService(result: .success([]))
        let viewModel = AccountsViewModel(service: service)

        await viewModel.fetchBanks()

        #expect(viewModel.creditAgricoleBanks.isEmpty)
        #expect(viewModel.otherBanks.isEmpty)
    }
}
