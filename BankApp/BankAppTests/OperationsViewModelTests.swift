import Testing
@testable import BankApp

private func makeAccount(operations: [Operation]) -> Account {
    Account(
        order: 1, id: "1", holder: "H", role: 1,
        contractNumber: "C", label: "Test",
        productCode: "P", balance: 0, operations: operations
    )
}

private func makeOperation(
    id: String = "1",
    title: String = "Op",
    amount: String = "-10,00",
    date: String = "1644870724"
) -> Operation {
    Operation(operationId: id, title: title, amount: amount, category: "misc", date: date)
}

@Suite("OperationsViewModel")
struct OperationsViewModelTests {

    @Suite("RG05 — Sort by date descending")
    struct SortByDate {
        @Test func operationsSortedByDateDescending() {
            let ops = [
                makeOperation(id: "1", title: "Oldest", date: "1000000000"),
                makeOperation(id: "2", title: "Newest", date: "1700000000"),
                makeOperation(id: "3", title: "Middle", date: "1400000000")
            ]
            let vm = OperationsViewModel(account: makeAccount(operations: ops))

            let titles = vm.sortedOperations.map(\.title)
            #expect(titles == ["Newest", "Middle", "Oldest"])
        }

        @Test func alreadySortedDescending_remainsUnchanged() {
            let ops = [
                makeOperation(id: "1", title: "First", date: "1700000000"),
                makeOperation(id: "2", title: "Second", date: "1400000000"),
                makeOperation(id: "3", title: "Third", date: "1000000000")
            ]
            let vm = OperationsViewModel(account: makeAccount(operations: ops))

            let titles = vm.sortedOperations.map(\.title)
            #expect(titles == ["First", "Second", "Third"])
        }

        @Test func sortedAscending_getsReversed() {
            let ops = [
                makeOperation(id: "1", title: "Old", date: "1000000000"),
                makeOperation(id: "2", title: "New", date: "1700000000")
            ]
            let vm = OperationsViewModel(account: makeAccount(operations: ops))

            #expect(vm.sortedOperations[0].title == "New")
            #expect(vm.sortedOperations[1].title == "Old")
        }
    }

    @Suite("RG06 — Same date, sort by title alphabetically")
    struct SameDateTitleSort {
        @Test func sameDateOperations_sortedAlphabetically() {
            let sameDate = "1644870724"
            let ops = [
                makeOperation(id: "1", title: "Netflix", date: sameDate),
                makeOperation(id: "2", title: "Amazon", date: sameDate),
                makeOperation(id: "3", title: "Carrefour", date: sameDate)
            ]
            let vm = OperationsViewModel(account: makeAccount(operations: ops))

            let titles = vm.sortedOperations.map(\.title)
            #expect(titles == ["Amazon", "Carrefour", "Netflix"])
        }

        @Test func sameDateTwoOperations_alphabetical() {
            let sameDate = "1644870724"
            let ops = [
                makeOperation(id: "1", title: "Zara", date: sameDate),
                makeOperation(id: "2", title: "Auchan", date: sameDate)
            ]
            let vm = OperationsViewModel(account: makeAccount(operations: ops))

            #expect(vm.sortedOperations[0].title == "Auchan")
            #expect(vm.sortedOperations[1].title == "Zara")
        }

        @Test func sameDateAlreadyAlphabetical_remainsUnchanged() {
            let sameDate = "1644870724"
            let ops = [
                makeOperation(id: "1", title: "Alpha", date: sameDate),
                makeOperation(id: "2", title: "Beta", date: sameDate)
            ]
            let vm = OperationsViewModel(account: makeAccount(operations: ops))

            let titles = vm.sortedOperations.map(\.title)
            #expect(titles == ["Alpha", "Beta"])
        }
    }

    @Suite("RG05 + RG06 — Combined sorting")
    struct CombinedSorting {
        @Test func mixedDatesAndSameDates_sortedCorrectly() {
            let ops = [
                makeOperation(id: "1", title: "Netflix", date: "1644870724"),
                makeOperation(id: "2", title: "Amazon", date: "1644870724"),
                makeOperation(id: "3", title: "Loyer", date: "1644611558"),
                makeOperation(id: "4", title: "Salaire", date: "1700000000")
            ]
            let vm = OperationsViewModel(account: makeAccount(operations: ops))

            let titles = vm.sortedOperations.map(\.title)
            #expect(titles == ["Salaire", "Amazon", "Netflix", "Loyer"])
        }

        @Test func threeDatesWithTiesOnEach_sortedCorrectly() {
            let ops = [
                makeOperation(id: "1", title: "C", date: "1000000000"),
                makeOperation(id: "2", title: "A", date: "1000000000"),
                makeOperation(id: "3", title: "Z", date: "2000000000"),
                makeOperation(id: "4", title: "M", date: "2000000000"),
                makeOperation(id: "5", title: "B", date: "1500000000")
            ]
            let vm = OperationsViewModel(account: makeAccount(operations: ops))

            let titles = vm.sortedOperations.map(\.title)
            #expect(titles == ["M", "Z", "B", "A", "C"])
        }

        @Test func realWorldScenario_banquePopOperations() {
            let ops = [
                makeOperation(id: "1", title: "Pret immo", amount: "-1331,44", date: "1644179569"),
                makeOperation(id: "2", title: "CB La Vie Claire", amount: "-53,20", date: "1644784369"),
                makeOperation(id: "3", title: "Prelevement Spotify", amount: "-10,00", date: "1644611558"),
                makeOperation(id: "4", title: "CB Billets SNCF", amount: "-53,00", date: "1644870724")
            ]
            let vm = OperationsViewModel(account: makeAccount(operations: ops))

            let titles = vm.sortedOperations.map(\.title)
            #expect(titles == [
                "CB Billets SNCF",
                "CB La Vie Claire",
                "Prelevement Spotify",
                "Pret immo"
            ])
        }
    }

    @Suite("Edge cases")
    struct EdgeCases {
        @Test func emptyOperations_returnsEmpty() {
            let vm = OperationsViewModel(account: makeAccount(operations: []))
            #expect(vm.sortedOperations.isEmpty)
        }

        @Test func singleOperation_returnsSingle() {
            let ops = [makeOperation(id: "1", title: "Only")]
            let vm = OperationsViewModel(account: makeAccount(operations: ops))

            #expect(vm.sortedOperations.count == 1)
            #expect(vm.sortedOperations[0].title == "Only")
        }

        @Test func accountPropertiesPreserved() {
            let account = Account(
                order: 2, id: "42", holder: "Jean", role: 1,
                contractNumber: "CT999", label: "Compte joint",
                productCode: "CJ", balance: 843.15, operations: []
            )
            let vm = OperationsViewModel(account: account)

            #expect(vm.account.label == "Compte joint")
            #expect(vm.account.holder == "Jean")
            #expect(vm.account.balance == 843.15)
        }

        @Test func allSameDate_allSortedByTitle() {
            let date = "1644870724"
            let ops = (1...5).map { idx in
                makeOperation(id: "\(idx)", title: "Op\(6 - idx)", date: date)
            }
            let vm = OperationsViewModel(account: makeAccount(operations: ops))

            let titles = vm.sortedOperations.map(\.title)
            #expect(titles == ["Op1", "Op2", "Op3", "Op4", "Op5"])
        }

        @Test func operationCount_matchesInput() {
            let ops = (1...10).map { idx in
                makeOperation(id: "\(idx)", title: "Op\(idx)", date: "\(1000000000 + idx)")
            }
            let vm = OperationsViewModel(account: makeAccount(operations: ops))

            #expect(vm.sortedOperations.count == 10)
        }
    }
}
