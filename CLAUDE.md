# BankApp — Claude Agent Configuration

## Project Overview
Mini banking app built as a technical test for Crédit Agricole.
Displays bank accounts grouped by type (CA / others) with 
operations detail screen. Data comes from Firebase REST API 
with automatic fallback to local JSON bundle.

## Tech Stack
- Swift 6.2
- SwiftUI (no UIKit)
- async/await (no Combine)
- @Observable (no ObservableObject / @Published)
- Swift Testing (@Test, #expect) — no XCTest
- Xcode 26.4

## Architecture
MVVM + Repository Pattern — strict layer separation:

- Models/        → Codable structs: Bank, Account, Operation
- ViewModels/    → @Observable classes, business logic only
- Views/         → SwiftUI views, no business logic
- Services/      → BankServiceProtocol + implementations
- Utilities/     → AppColors enum, extensions, formatters

## Git Workflow
- Branches: main → develop → feature/xxx
- Always branch from develop
- PR target: always develop
- Commit format: Conventional Commits
  feat, fix, test, refactor, docs, chore
  Example: feat(service): add NetworkBankService with fallback

## Coding Standards
- Comments in English only
- No force unwrap (!)
- No magic color strings → always use AppColors enum
- No UIKit, no Combine, no ObservableObject, no DispatchQueue
- Use @Observable for all ViewModels
- Use async/await for all async operations
- Use typed throws at service boundaries
- #Preview macro on every SwiftUI view with mock data
- Prefer value types (structs) over classes for models
- Mark everything with appropriate access control

## Colors
Never use Color("name") magic strings.
Always use AppColors enum via Color extensions.
To add a new color: add to Assets.xcassets first,
then add case to AppColors, then add static extension on Color.

## Services
- BankServiceProtocol defines the contract
- NetworkBankService fetches from Firebase URL
- LocalBankService reads banks.json from app bundle
- On network failure → automatic fallback to LocalBankService
- Typed throws: func fetchBanks() async throws(BankError) -> [Bank]

## Testing Policy
After every new Swift file created, always generate the 
corresponding test file in BankAppTests/.
Never consider a task complete without tests.
Use Swift Testing framework only (@Test, #expect).
Mock services via MockBankService conforming to BankServiceProtocol.
Inject dependencies via init — never instantiate services inside ViewModels.
Target 80%+ coverage on Models and ViewModels.

## Verification
After every code change:
- Verify build succeeds (Cmd+B)
- Verify all tests pass (Cmd+U)
- Never say "done" without confirming both succeed
- Show build and test result as evidence before finishing

## What NOT to do
- No UIKit — SwiftUI only
- No Combine — async/await only
- No ObservableObject / @Published — use @Observable
- No DispatchQueue — use async/await and actors
- No force unwrap (!) anywhere
- No magic color strings — Color("name") is forbidden
- No hardcoded credentials or API keys in code
- No XCTest — use Swift Testing only
- No Storyboards or XIB files
- No singleton services — inject via protocol
