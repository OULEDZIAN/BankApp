//
//  OperationsView.swift
//  BankApp
//
//  Created by AOZ on 31/05/2026.
//

import SwiftUI

struct OperationsView: View {
    @State private var viewModel: OperationsViewModel
    @Environment(\.accessibilityDifferentiateWithoutColor) private var differentiateWithoutColor
    
    init(account: Account) {
        self._viewModel = State(initialValue: OperationsViewModel(account: account))
    }
    
    var body: some View {
        List {
            Section {
                Text(viewModel.formattedBalance)
                    .font(.title.monospacedDigit().bold())
                    .foregroundStyle(
                        viewModel.isNegativeBalance && !differentiateWithoutColor
                        ? Color.caAmountNegative : .primary
                    )
                    .frame(maxWidth: .infinity, alignment: .center)
                    .accessibilityLabel(
                        viewModel.isNegativeBalance
                        ? AppStrings.Accessibility.negativeBalance(viewModel.formattedBalance)
                        : AppStrings.Accessibility.balance(viewModel.formattedBalance)
                    )
            }
            
            Section {
                ForEach(viewModel.sortedOperations) { operation in
                    ViewThatFits(in: .horizontal) {
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(operation.title)
                                    .font(.subheadline)
                                    .foregroundStyle(.primary)
                                Text(operation.formattedDate)
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                            Spacer()
                            Text(operation.formattedAmount)
                                .font(.subheadline.monospacedDigit())
                                .foregroundStyle(
                                    operation.isNegative && !differentiateWithoutColor
                                    ? Color.caAmountNegative : .primary
                                )
                                .fontWeight(
                                    operation.isNegative && differentiateWithoutColor
                                    ? .bold : .regular
                                )
                        }
                        
                        VStack(alignment: .leading, spacing: 4) {
                            HStack {
                                Text(operation.title)
                                    .font(.subheadline)
                                    .foregroundStyle(.primary)
                                Spacer()
                                Text(operation.formattedAmount)
                                    .font(.subheadline.monospacedDigit())
                                    .foregroundStyle(
                                        operation.isNegative && !differentiateWithoutColor
                                        ? Color.caAmountNegative : .primary
                                    )
                                    .fontWeight(
                                        operation.isNegative && differentiateWithoutColor
                                        ? .bold : .regular
                                    )
                            }
                            Text(operation.formattedDate)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                    .accessibilityElement(children: .ignore)
                    .accessibilityLabel("\(operation.title), \(operation.accessibilityDate), \(operation.accessibilityAmount)")
                }
            }
        }
        .navigationTitle(viewModel.accountLabel)
    }
}

#Preview {
    let account = Account(
        order: 1, id: "1", holder: "Corinne Martin", role: 1,
        contractNumber: "CT001", label: "Compte de depot",
        productCode: "CD", balance: 2031.84,
        operations: [
            BankOperation(operationId: "1", title: "Prelevement Netflix", amount: "-15,99",
                          category: "leisure", date: "1644870724"),
            BankOperation(operationId: "2", title: "CB Amazon", amount: "-95,99",
                          category: "online", date: "1644611558"),
            BankOperation(operationId: "3", title: "Virement salaire", amount: "2500,00",
                          category: "income", date: "1644870724")
        ]
    )
    NavigationStack {
        OperationsView(account: account)
    }
}
