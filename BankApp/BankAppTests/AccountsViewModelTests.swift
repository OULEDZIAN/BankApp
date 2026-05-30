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
}
