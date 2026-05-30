//
//  AccountRowView.swift
//  BankApp
//
//  Created by AOZ on 30/05/2026.
//

import SwiftUI

struct AccountRowView: View {
    let account: Account

    var body: some View {
        NavigationLink {
            OperationsView(account: account)
        } label: {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(account.label)
                        .font(.subheadline)
                        .foregroundStyle(.primary)
                    Text(account.holder)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                Spacer()
                Text(account.formattedBalance)
                    .font(.subheadline.monospacedDigit())
                    .foregroundStyle(account.balance < 0 ? Color.caAmountNegative : .primary)
            }
            .padding(.leading, 16)
        }
    }
}

#Preview {
    let accounts = [
        Account(
            order: 0, id: "1", holder: "Corinne Martin", role: 1,
            contractNumber: "CT001", label: "Compte de dépôt",
            productCode: "CD", balance: 2031.84, operations: []
        ),
        Account(
            order: 1, id: "2", holder: "M. et Mme Martin", role: 2,
            contractNumber: "CT002", label: "Compte joint",
            productCode: "CJ", balance: -150.30, operations: []
        )
    ]
    NavigationStack {
        List {
            ForEach(accounts) { account in
                AccountRowView(account: account)
            }
        }
    }
}
