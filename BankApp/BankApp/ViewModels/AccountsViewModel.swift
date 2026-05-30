//
//  AccountsViewModel.swift
//  BankApp
//
//  Created by AOZ on 30/05/2026.
//

import Foundation

/// Fetches and groups bank accounts by Crédit Agricole vs other banks (RG00).
/// Manages expand/collapse state for each bank row (RG01).
@Observable
final class AccountsViewModel {
    private let service: BankServiceProtocol
    private(set) var allBanks: [Bank] = []
    private var expandedBanks: Set<String> = []

    var state: LoadingState = .idle

    var creditAgricoleBanks: [Bank] {
        allBanks.filter { $0.isCreditAgricole }.sorted { $0.name < $1.name }
    }

    var otherBanks: [Bank] {
        allBanks.filter { !$0.isCreditAgricole }.sorted { $0.name < $1.name }
    }

    init(service: BankServiceProtocol = NetworkBankService()) {
        self.service = service
    }

    func fetchBanks() async {
        let isRefresh = if case .loaded = state { true } else { false }
        if !isRefresh {
            state = .loading
        }
        do {
            let banks = try await service.fetchBanks()
            allBanks = banks
            state = .loaded(banks)
        } catch BankError.networkUnavailable {
            state = .error(.networkUnavailable)
        } catch {
            state = .error(.decodingFailed)
        }
    }

    func toggleExpand(bankName: String) {
        if expandedBanks.contains(bankName) {
            expandedBanks.remove(bankName)
        } else {
            expandedBanks.insert(bankName)
        }
    }

    func isExpanded(bankName: String) -> Bool {
        expandedBanks.contains(bankName)
    }
}
