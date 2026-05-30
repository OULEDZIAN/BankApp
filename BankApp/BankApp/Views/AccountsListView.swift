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
                .refreshable {
                    await viewModel.fetchBanks()
                }
            
        case .error(let error):
            let icon = switch error {
            case .networkUnavailable: "wifi.slash"
            case .decodingFailed: "exclamationmark.triangle"
            }
            ScrollView {
                ContentUnavailableView {
                    Label(error.errorDescription ?? "", systemImage: icon)
                } description: {
                    Text(AppStrings.Error.pullToRefresh)
                }
            }
            .refreshable {
                await viewModel.fetchBanks()
            }
        }
    }
    
    @ViewBuilder
    private func bankCell(_ bank: Bank) -> some View {
        BankRowView(
            bank: bank,
            isExpanded: viewModel.isExpanded(bankName: bank.name),
            onToggle: {
                withAnimation {
                    viewModel.toggleExpand(bankName: bank.name)
                }
            }
        )
        if viewModel.isExpanded(bankName: bank.name) {
            ForEach(bank.sortedAccounts) { account in
                AccountRowView(account: account)
            }
        }
    }

    private var bankList: some View {
        List {
            if !viewModel.creditAgricoleBanks.isEmpty {
                Section {
                    ForEach(viewModel.creditAgricoleBanks) { bank in
                        bankCell(bank)
                    }
                } header: {
                    Text(AppStrings.Section.creditAgricole)
                        .foregroundStyle(.primary)
                }
            }

            if !viewModel.otherBanks.isEmpty {
                Section {
                    ForEach(viewModel.otherBanks) { bank in
                        bankCell(bank)
                    }
                } header: {
                    Text(AppStrings.Section.otherBanks)
                        .foregroundStyle(.primary)
                }
            }
        }
    }
}

#Preview("Loading") {
    let service = PreviewLoadingService()
    AccountsListView(viewModel: AccountsViewModel(service: service))
}

#Preview("Loaded") {
    let service = PreviewLoadedService()
    AccountsListView(viewModel: AccountsViewModel(service: service))
}

#Preview("Error - Network") {
    let service = PreviewErrorService(error: .networkUnavailable)
    AccountsListView(viewModel: AccountsViewModel(service: service))
}

#Preview("Error - Decoding") {
    let service = PreviewErrorService(error: .decodingFailed)
    AccountsListView(viewModel: AccountsViewModel(service: service))
}

// MARK: - Preview Services

private struct PreviewLoadingService: BankServiceProtocol {
    func fetchBanks() async throws(BankError) -> [Bank] {
        try? await Task.sleep(for: .seconds(999))
        return []
    }
}

private struct PreviewLoadedService: BankServiceProtocol {
    func fetchBanks() async throws(BankError) -> [Bank] {
        [
            Bank(name: "CA Languedoc", isCA: 1, accounts: [
                Account(
                    order: 0, id: "1", holder: "Jean Dupont", role: 1,
                    contractNumber: "CT001", label: "Compte de dépôt",
                    productCode: "CD", balance: 2031.84, operations: []
                ),
                Account(
                    order: 1, id: "2", holder: "Jean Dupont", role: 1,
                    contractNumber: "CT002", label: "Compte joint",
                    productCode: "CJ", balance: 843.15, operations: []
                ),
                Account(
                    order: 2, id: "3", holder: "Jean Dupont", role: 1,
                    contractNumber: "CT003", label: "Compte Mozaïc",
                    productCode: "CM", balance: 209.39, operations: []
                )
            ]),
            Bank(name: "CA Centre-Est", isCA: 1, accounts: [
                Account(
                    order: 0, id: "4", holder: "Jean Dupont", role: 1,
                    contractNumber: "CT004", label: "Compte de dépôt",
                    productCode: "CD", balance: 425.84, operations: []
                )
            ]),
            Bank(name: "Boursorama", isCA: 0, accounts: [
                Account(
                    order: 0, id: "5", holder: "Jean Dupont", role: 1,
                    contractNumber: "CT005", label: "Compte de dépôt",
                    productCode: "CD", balance: 45.84, operations: []
                )
            ]),
            Bank(name: "Banque Pop", isCA: 0, accounts: [
                Account(
                    order: 0, id: "6", holder: "Jean Dupont", role: 1,
                    contractNumber: "CT006", label: "Compte Chèques",
                    productCode: "CC", balance: 675.04, operations: []
                )
            ])
        ]
    }
}

private struct PreviewErrorService: BankServiceProtocol {
    let error: BankError
    
    func fetchBanks() async throws(BankError) -> [Bank] {
        throw error
    }
}
