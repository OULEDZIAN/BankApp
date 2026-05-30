//
//  AccountsViewModelTests.swift
//  BankAppTests
//
//  Created by AOZ on 30/05/2026.
//

import Testing
@testable import BankApp

@Suite("AccountsViewModel")
struct AccountsViewModelTests {
    private let mockBanks = [
        Bank(name: "Crédit Agricole Centre", isCA: 1, accounts: []),
        Bank(name: "Crédit Agricole Sud", isCA: 1, accounts: []),
        Bank(name: "BNP Paribas", isCA: 0, accounts: [])
    ]
    
    @Suite("RG00 — Grouping")
    struct Grouping {
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
        
        @MainActor @Test func creditAgricoleBanks_emptyBeforeFetch() {
            let service = MockBankService(result: .success(mockBanks))
            let viewModel = AccountsViewModel(service: service)
            
            #expect(viewModel.creditAgricoleBanks.isEmpty)
        }
    }
    
    @Suite("Fetch State")
    struct FetchState {
        private let mockBanks = [
            Bank(name: "Crédit Agricole Centre", isCA: 1, accounts: []),
            Bank(name: "Crédit Agricole Sud", isCA: 1, accounts: []),
            Bank(name: "BNP Paribas", isCA: 0, accounts: [])
        ]
        
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
        
        @MainActor @Test func fetchBanks_withEmptyResponse() async {
            let service = MockBankService(result: .success([]))
            let viewModel = AccountsViewModel(service: service)
            
            await viewModel.fetchBanks()
            
            #expect(viewModel.creditAgricoleBanks.isEmpty)
            #expect(viewModel.otherBanks.isEmpty)
        }
    }
    
    @Suite("RG01 — Expand / Collapse")
    struct ExpandCollapse {
        private let mockBanks = [
            Bank(name: "Crédit Agricole Centre", isCA: 1, accounts: []),
            Bank(name: "Crédit Agricole Sud", isCA: 1, accounts: []),
            Bank(name: "BNP Paribas", isCA: 0, accounts: [])
        ]
        
        @MainActor @Test func toggleExpand_expandsCollapsedBank() {
            let service = MockBankService(result: .success(mockBanks))
            let viewModel = AccountsViewModel(service: service)
            
            #expect(!viewModel.isExpanded(bankName: "Crédit Agricole Centre"))
            
            viewModel.toggleExpand(bankName: "Crédit Agricole Centre")
            
            #expect(viewModel.isExpanded(bankName: "Crédit Agricole Centre"))
        }
        
        @MainActor @Test func toggleExpand_collapsesExpandedBank() {
            let service = MockBankService(result: .success(mockBanks))
            let viewModel = AccountsViewModel(service: service)
            
            viewModel.toggleExpand(bankName: "BNP Paribas")
            #expect(viewModel.isExpanded(bankName: "BNP Paribas"))
            
            viewModel.toggleExpand(bankName: "BNP Paribas")
            #expect(!viewModel.isExpanded(bankName: "BNP Paribas"))
        }
        
        @MainActor @Test func toggleExpand_independentPerBank() {
            let service = MockBankService(result: .success(mockBanks))
            let viewModel = AccountsViewModel(service: service)

            viewModel.toggleExpand(bankName: "Crédit Agricole Centre")
            viewModel.toggleExpand(bankName: "BNP Paribas")

            #expect(viewModel.isExpanded(bankName: "Crédit Agricole Centre"))
            #expect(viewModel.isExpanded(bankName: "BNP Paribas"))
            #expect(!viewModel.isExpanded(bankName: "Crédit Agricole Sud"))
        }
    }

    @Suite("RG02 — Sections")
    struct Sections {
        private let mockBanks = [
            Bank(name: "Crédit Agricole Centre", isCA: 1, accounts: []),
            Bank(name: "Crédit Agricole Sud", isCA: 1, accounts: []),
            Bank(name: "BNP Paribas", isCA: 0, accounts: [])
        ]

        @MainActor @Test func creditAgricoleBanks_appearsInFirstSection() async {
            let service = MockBankService(result: .success(mockBanks))
            let viewModel = AccountsViewModel(service: service)

            await viewModel.fetchBanks()

            #expect(!viewModel.creditAgricoleBanks.isEmpty)
            #expect(viewModel.creditAgricoleBanks.count == 2)
        }

        @MainActor @Test func otherBanks_appearsInSecondSection() async {
            let service = MockBankService(result: .success(mockBanks))
            let viewModel = AccountsViewModel(service: service)

            await viewModel.fetchBanks()

            #expect(!viewModel.otherBanks.isEmpty)
            #expect(viewModel.otherBanks.count == 1)
        }
    }

    @Suite("RG03 — Sorting")
    struct Sorting {
        @MainActor @Test func creditAgricoleBanks_sortedAlphabetically() async {
            let banks = [
                Bank(name: "CA Sud", isCA: 1, accounts: []),
                Bank(name: "CA Centre", isCA: 1, accounts: []),
                Bank(name: "CA Languedoc", isCA: 1, accounts: [])
            ]
            let service = MockBankService(result: .success(banks))
            let viewModel = AccountsViewModel(service: service)

            await viewModel.fetchBanks()

            let names = viewModel.creditAgricoleBanks.map(\.name)
            #expect(names == ["CA Centre", "CA Languedoc", "CA Sud"])
        }

        @MainActor @Test func otherBanks_sortedAlphabetically() async {
            let banks = [
                Bank(name: "Société Générale", isCA: 0, accounts: []),
                Bank(name: "BNP Paribas", isCA: 0, accounts: []),
                Bank(name: "Boursorama", isCA: 0, accounts: [])
            ]
            let service = MockBankService(result: .success(banks))
            let viewModel = AccountsViewModel(service: service)

            await viewModel.fetchBanks()

            let names = viewModel.otherBanks.map(\.name)
            #expect(names == ["BNP Paribas", "Boursorama", "Société Générale"])
        }

        @MainActor @Test func alreadySorted_remainsUnchanged() async {
            let banks = [
                Bank(name: "CA Alpha", isCA: 1, accounts: []),
                Bank(name: "CA Beta", isCA: 1, accounts: [])
            ]
            let service = MockBankService(result: .success(banks))
            let viewModel = AccountsViewModel(service: service)

            await viewModel.fetchBanks()

            let names = viewModel.creditAgricoleBanks.map(\.name)
            #expect(names == ["CA Alpha", "CA Beta"])
        }

        @MainActor @Test func reverseSorted_getsCorrected() async {
            let banks = [
                Bank(name: "CA Zèbre", isCA: 1, accounts: []),
                Bank(name: "CA Azur", isCA: 1, accounts: [])
            ]
            let service = MockBankService(result: .success(banks))
            let viewModel = AccountsViewModel(service: service)

            await viewModel.fetchBanks()

            let names = viewModel.creditAgricoleBanks.map(\.name)
            #expect(names == ["CA Azur", "CA Zèbre"])
        }

        @MainActor @Test func singleBank_returnsSingleElement() async {
            let banks = [
                Bank(name: "CA Unique", isCA: 1, accounts: [])
            ]
            let service = MockBankService(result: .success(banks))
            let viewModel = AccountsViewModel(service: service)

            await viewModel.fetchBanks()

            #expect(viewModel.creditAgricoleBanks.count == 1)
            #expect(viewModel.creditAgricoleBanks[0].name == "CA Unique")
        }

        @MainActor @Test func emptyList_returnsEmpty() async {
            let service = MockBankService(result: .success([]))
            let viewModel = AccountsViewModel(service: service)

            await viewModel.fetchBanks()

            #expect(viewModel.creditAgricoleBanks.isEmpty)
            #expect(viewModel.otherBanks.isEmpty)
        }

        @MainActor @Test func sameFirstLetter_sortsByFullName() async {
            let banks = [
                Bank(name: "Banque Pop", isCA: 0, accounts: []),
                Bank(name: "Boursorama", isCA: 0, accounts: []),
                Bank(name: "BNP Paribas", isCA: 0, accounts: [])
            ]
            let service = MockBankService(result: .success(banks))
            let viewModel = AccountsViewModel(service: service)

            await viewModel.fetchBanks()

            let names = viewModel.otherBanks.map(\.name)
            #expect(names == ["BNP Paribas", "Banque Pop", "Boursorama"])
        }

        @MainActor @Test func endToEnd_bothSectionsSortedAfterFetch() async {
            let banks = [
                Bank(name: "CA Sud", isCA: 1, accounts: []),
                Bank(name: "Société Générale", isCA: 0, accounts: []),
                Bank(name: "CA Centre", isCA: 1, accounts: []),
                Bank(name: "BNP Paribas", isCA: 0, accounts: []),
                Bank(name: "CA Languedoc", isCA: 1, accounts: []),
                Bank(name: "Boursorama", isCA: 0, accounts: [])
            ]
            let service = MockBankService(result: .success(banks))
            let viewModel = AccountsViewModel(service: service)

            await viewModel.fetchBanks()

            let caNames = viewModel.creditAgricoleBanks.map(\.name)
            let otherNames = viewModel.otherBanks.map(\.name)
            #expect(caNames == ["CA Centre", "CA Languedoc", "CA Sud"])
            #expect(otherNames == ["BNP Paribas", "Boursorama", "Société Générale"])
        }
    }
}
