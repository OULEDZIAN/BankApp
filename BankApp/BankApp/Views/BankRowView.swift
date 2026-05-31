//
//  BankRowView.swift
//  BankApp
//
//  Created by AOZ on 30/05/2026.
//

import SwiftUI

struct BankRowView: View {
    let bank: Bank
    let isExpanded: Bool
    let onToggle: () -> Void
    
    var body: some View {
        Button(action: onToggle) {
            HStack {
                Text(bank.name)
                    .font(.headline)
                    .foregroundStyle(.primary)
                Spacer()
                Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                    .foregroundStyle(Color.caAccent)
                    .accessibilityHidden(true)
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityLabel(bank.name)
        .accessibilityValue(isExpanded ? AppStrings.Accessibility.Bank.expanded : AppStrings.Accessibility.Bank.collapsed)
        .accessibilityHint(isExpanded ? AppStrings.Accessibility.Bank.collapseHint : AppStrings.Accessibility.Bank.expandHint)
    }
}

#Preview {
    let bank = Bank(
        name: "Crédit Agricole Centre",
        isCA: 1,
        accounts: []
    )
    List {
        BankRowView(bank: bank, isExpanded: false, onToggle: {})
        BankRowView(bank: bank, isExpanded: true, onToggle: {})
    }
}
