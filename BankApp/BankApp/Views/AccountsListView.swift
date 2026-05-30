//
//  AccountsListView.swift
//  BankApp
//
//  Created by AOZ on 30/05/2026.
//

import SwiftUI

struct AccountsListView: View {
    @State private var viewModel: AccountsViewModel

    init(viewModel: AccountsViewModel = AccountsViewModel()) {
        self._viewModel = State(initialValue: viewModel)
    }

    var body: some View {
        NavigationStack {
            content
                .navigationTitle(AppStrings.Accounts.title)
                .background(Color.caBackgroundPrimary)
        }
        .task {
            await viewModel.fetchBanks()
        }
    }

    @ViewBuilder
    private var content: some View {
        switch viewModel.state {
        case .idle, .loading:
            ProgressView()
                .frame(maxWidth: .infinity, maxHeight: .infinity)

        case .loaded:
            bankList

        case .error(let error):
            let icon = switch error {
            case .networkUnavailable: "wifi.slash"
            case .decodingFailed: "exclamationmark.triangle"
            }
            ContentUnavailableView(
                error.errorDescription ?? "",
                systemImage: icon
            )
        }
    }

    private var bankList: some View {
        List {
            ForEach(viewModel.allBanks) { bank in
                BankRowView(
                    bank: bank,
                    isExpanded: viewModel.isExpanded(bankName: bank.name),
                    onToggle: { viewModel.toggleExpand(bankName: bank.name) }
                )
            }
        }
    }
}

#Preview("Loading") {
    let service = PreviewBankService(state: .loading)
    AccountsListView(viewModel: AccountsViewModel(service: service))
}

#Preview("Loaded") {
    let service = PreviewBankService(state: .loaded)
    AccountsListView(viewModel: AccountsViewModel(service: service))
}

#Preview("Error") {
    let service = PreviewBankService(state: .error)
    AccountsListView(viewModel: AccountsViewModel(service: service))
}

/// Preview-only service for simulating different states.
private struct PreviewBankService: BankServiceProtocol {
    enum PreviewState {
        case loading, loaded, error
    }

    let state: PreviewState

    func fetchBanks() async throws(BankError) -> [Bank] {
        switch state {
        case .loading:
            try? await Task.sleep(for: .seconds(999))
            return []
        case .loaded:
            return [
                Bank(name: "Crédit Agricole Centre", isCA: 1, accounts: [
                    Account(
                        order: 0, id: "1", holder: "Jean Dupont", role: 1,
                        contractNumber: "CT001", label: "Compte Courant",
                        productCode: "CC", balance: 1234.56, operations: []
                    )
                ]),
                Bank(name: "BNP Paribas", isCA: 0, accounts: [
                    Account(
                        order: 0, id: "2", holder: "Jean Dupont", role: 1,
                        contractNumber: "CT002", label: "Livret A",
                        productCode: "LA", balance: -45.30, operations: []
                    )
                ])
            ]
        case .error:
            throw .networkUnavailable
        }
    }
}
