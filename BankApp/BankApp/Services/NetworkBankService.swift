//
//  NetworkBankService.swift
//  BankApp
//
//  Created by AOZ on 29/05/2026.
//

import Foundation

/// Fetches bank data from the Firebase REST API.
struct NetworkBankService: BankServiceProtocol {
    private let url = URL(string: "https://cdf-test-mobile-default-rtdb.europe-west1.firebasedatabase.app/banks.json")

    func fetchBanks() async throws(BankError) -> [Bank] {
        guard let url else {
            throw .networkUnavailable
        }

        let data: Data
        do {
            (data, _) = try await URLSession.shared.data(from: url)
        } catch {
            throw .networkUnavailable
        }

        do {
            let response = try JSONDecoder().decode(BankResponse.self, from: data)
            return response.banks
        } catch {
            throw .decodingFailed
        }
    }
}
