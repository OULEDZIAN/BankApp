import Testing
@testable import BankApp

private let mockBanks = [
    Bank(name: "Crédit Agricole Centre", isCA: 1, accounts: []),
    Bank(name: "Crédit Agricole Sud", isCA: 1, accounts: []),
    Bank(name: "BNP Paribas", isCA: 0, accounts: [])
]

@Suite("AccountsViewModel")
struct AccountsViewModelTests {
    @Suite("RG00 — Grouping")
    struct Grouping {
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

    @Suite("RG04 — Account Details")
    struct AccountDetails {
        @Test func sortedAccounts_respectsOrderField() {
            let accounts = [
                Account(order: 3, id: "3", holder: "H", role: 1,
                        contractNumber: "C", label: "Third",
                        productCode: "P", balance: 0, operations: []),
                Account(order: 1, id: "1", holder: "H", role: 1,
                        contractNumber: "C", label: "First",
                        productCode: "P", balance: 0, operations: []),
                Account(order: 2, id: "2", holder: "H", role: 1,
                        contractNumber: "C", label: "Second",
                        productCode: "P", balance: 0, operations: [])
            ]
            let bank = Bank(name: "Test", isCA: 1, accounts: accounts)

            let sorted = bank.sortedAccounts
            #expect(sorted.map(\.label) == ["First", "Second", "Third"])
        }

        @Test func sortedAccounts_emptyReturnsEmpty() {
            let bank = Bank(name: "Test", isCA: 1, accounts: [])
            #expect(bank.sortedAccounts.isEmpty)
        }
        @Test func sortedAccounts_singleAccount() {
            let accounts = [
                Account(order: 1, id: "1", holder: "H", role: 1,
                        contractNumber: "C", label: "Only",
                        productCode: "P", balance: 100, operations: [])
            ]
            let bank = Bank(name: "Test", isCA: 1, accounts: accounts)

            #expect(bank.sortedAccounts.count == 1)
            #expect(bank.sortedAccounts[0].label == "Only")
        }

        @Test func sortedAccounts_alreadySortedUnchanged() {
            let accounts = [
                Account(order: 1, id: "1", holder: "H", role: 1,
                        contractNumber: "C", label: "Alpha",
                        productCode: "P", balance: 0, operations: []),
                Account(order: 2, id: "2", holder: "H", role: 1,
                        contractNumber: "C", label: "Beta",
                        productCode: "P", balance: 0, operations: [])
            ]
            let bank = Bank(name: "Test", isCA: 1, accounts: accounts)

            #expect(bank.sortedAccounts.map(\.label) == ["Alpha", "Beta"])
        }

        @MainActor @Test func expandedBank_accountsAccessible() async {
            let accounts = [
                Account(order: 1, id: "1", holder: "Corinne", role: 1,
                        contractNumber: "CT001", label: "Compte de dépôt",
                        productCode: "CD", balance: 2031.84, operations: []),
                Account(order: 2, id: "2", holder: "Jean", role: 1,
                        contractNumber: "CT002", label: "Compte joint",
                        productCode: "CJ", balance: 843.15, operations: [])
            ]
            let banks = [
                Bank(name: "CA Test", isCA: 1, accounts: accounts)
            ]
            let service = MockBankService(result: .success(banks))
            let viewModel = AccountsViewModel(service: service)

            await viewModel.fetchBanks()
            viewModel.toggleExpand(bankName: "CA Test")

            #expect(viewModel.isExpanded(bankName: "CA Test"))
            let bank = viewModel.creditAgricoleBanks.first
            #expect(bank?.sortedAccounts.count == 2)
            #expect(bank?.sortedAccounts[0].label == "Compte de dépôt")
            #expect(bank?.sortedAccounts[1].label == "Compte joint")
        }

        @MainActor @Test func collapsedBank_accountsStillExistButHidden() async {
            let accounts = [
                Account(order: 1, id: "1", holder: "H", role: 1,
                        contractNumber: "C", label: "Compte",
                        productCode: "P", balance: 100, operations: [])
            ]
            let banks = [
                Bank(name: "CA Test", isCA: 1, accounts: accounts)
            ]
            let service = MockBankService(result: .success(banks))
            let viewModel = AccountsViewModel(service: service)

            await viewModel.fetchBanks()

            #expect(!viewModel.isExpanded(bankName: "CA Test"))
            #expect(viewModel.creditAgricoleBanks.first?.accounts.count == 1)
        }

        @MainActor @Test func multipleBanks_independentAccountLists() async {
            let banks = [
                Bank(name: "CA Sud", isCA: 1, accounts: [
                    Account(order: 1, id: "1", holder: "H", role: 1,
                            contractNumber: "C", label: "Dépôt",
                            productCode: "P", balance: 500, operations: [])
                ]),
                Bank(name: "CA Nord", isCA: 1, accounts: [
                    Account(order: 1, id: "2", holder: "H", role: 1,
                            contractNumber: "C", label: "Joint",
                            productCode: "P", balance: 300, operations: []),
                    Account(order: 2, id: "3", holder: "H", role: 1,
                            contractNumber: "C", label: "Mozaïc",
                            productCode: "P", balance: 50, operations: [])
                ])
            ]
            let service = MockBankService(result: .success(banks))
            let viewModel = AccountsViewModel(service: service)

            await viewModel.fetchBanks()
            viewModel.toggleExpand(bankName: "CA Sud")
            viewModel.toggleExpand(bankName: "CA Nord")

            let caBanks = viewModel.creditAgricoleBanks
            let sud = caBanks.first { $0.name == "CA Sud" }
            let nord = caBanks.first { $0.name == "CA Nord" }

            #expect(sud?.sortedAccounts.count == 1)
            #expect(nord?.sortedAccounts.count == 2)
        }

        @Test func accountFormattedBalance_positiveBalance() {
            let account = Account(
                order: 1, id: "1", holder: "H", role: 1,
                contractNumber: "C", label: "Test",
                productCode: "P", balance: 2031.84, operations: []
            )
            #expect(account.formattedBalance == "2 031,84 €")
        }
        @Test func accountFormattedBalance_negativeBalance() {
            let account = Account(
                order: 1, id: "1", holder: "H", role: 1,
                contractNumber: "C", label: "Test",
                productCode: "P", balance: -150.30, operations: []
            )
            #expect(account.formattedBalance == "-150,30 €")
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
