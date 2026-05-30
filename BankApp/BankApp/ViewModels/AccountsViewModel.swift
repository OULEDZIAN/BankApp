//
//  AccountsViewModel.swift
//  BankApp
//
//  Created by AOZ on 30/05/2026.
//

import Foundation

/// Fetches and groups bank accounts by Crédit Agricole vs other banks (RG00).
@Observable
final class AccountsViewModel {
    private let service: BankServiceProtocol
    private var allBanks: [Bank] = []

    var state: LoadingState = .idle

    var creditAgricoleBanks: [Bank] {
        allBanks.filter { $0.isCreditAgricole }
    }

    var otherBanks: [Bank] {
        allBanks.filter { !$0.isCreditAgricole }
    }

    init(service: BankServiceProtocol = NetworkBankService()) {
        self.service = service
    }

    func fetchBanks() async {
        state = .loading
        do {
            let banks = try await service.fetchBanks()
            allBanks = banks
            state = .loaded(banks)
        } catch BankError.networkUnavailable {
            state = .error(AppStrings.Error.networkUnavailable)
        } catch {
            state = .error(AppStrings.Error.decodingFailed)
        }
    }
}
