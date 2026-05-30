import Foundation

/// Provides sorted operations for a given account (RG05, RG06).
@Observable
final class OperationsViewModel {
    let account: Account

    var sortedOperations: [Operation] {
        account.operations.sorted { lhs, rhs in
            if lhs.timestamp != rhs.timestamp {
                return lhs.timestamp > rhs.timestamp
            }
            return lhs.title.localizedCompare(rhs.title) == .orderedAscending
        }
    }

    init(account: Account) {
        self.account = account
    }
}
