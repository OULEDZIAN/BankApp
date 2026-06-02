# BankApp — Test Technique Crédit Agricole

## Résumé

> Mini-application bancaire iOS réalisée dans le cadre du test technique CA.

L'app récupère les données depuis l'API Firebase fournie et les présente 
en **deux écrans** :

- 📋 **Liste des comptes** — groupés Crédit Agricole / autres, 
  triés alphabétiquement, avec cellules dépliantes
- 💳 **Détail des opérations** — triées par date décroissante, 
  avec gestion de l'égalité par ordre alphabétique

---

**Stack** · Swift 6.2 · SwiftUI · async/await · @Observable · Xcode 26.4

## Captures d'écran

### 📱 Light Mode
| Liste des comptes | Comptes dépliés | Opérations |
|---|---|---|
| <img width="200" src="https://github.com/user-attachments/assets/42e72bd5-fec5-4c5c-8084-0aed9db8a1b8"> | <img width="200" src="https://github.com/user-attachments/assets/9aabb072-9ba7-4040-bdcb-f0376b2777b5"> | <img width="200" src="https://github.com/user-attachments/assets/2664d817-86a6-43d0-911e-ccd03625ceae"> |

### 🌙 Dark Mode
| Liste des comptes | Opérations |
|---|---|
| <img width="200" alt="Simulator Screenshot - iPhone 17 - 2026-06-01 at 02 48 54" src="https://github.com/user-attachments/assets/ab20f4c1-aa4d-4cbe-b5c5-293ea042fc38" /> | <img width="200" alt="Simulator Screenshot - iPhone 17 - 2026-06-01 at 02 49 06" src="https://github.com/user-attachments/assets/ddb0ed37-ae96-4a0e-9fd7-11ecef43d00c" /> |

### ♿ Accessibilité
| Écran 1 | Écran 2 |
|---|---|
| <img width="200"  alt="Simulator Screenshot - iPhone 17 - 2026-06-01 at 02 53 23" src="https://github.com/user-attachments/assets/05758116-d122-4eda-93c1-cdae2b4f22b2" /> | <img width="200"  alt="Simulator Screenshot - iPhone 17 - 2026-06-01 at 02 53 29" src="https://github.com/user-attachments/assets/4b6ed456-15c7-4144-8213-902af3a79f54" /> |

### 🎬 Demo
> 🔄 GIF — Navigation complète de l'app

<img width="200"  alt="Simulator Screen Recording - iPhone 17 - 2026-06-01 at 03 43 42" src="https://github.com/user-attachments/assets/b237d70e-fe80-4b89-afb2-3cd064401066" />

> 🔊 VoiceOver avec son — cliquer pour écouter

[▶ Watch VoiceOver Demo](https://www.loom.com/share/1c44efe9f3564f4cbd082d661c8bb441)

## Architecture

L'application suit le pattern **MVVM + Repository** avec une séparation stricte des responsabilités.

**Structure des dossiers**

    BankApp/
    ├── Models/          → Structs Codable (Bank, Account, BankOperation)
    ├── ViewModels/      → Logique métier (@Observable, async/await)
    ├── Views/           → SwiftUI pur, zéro logique
    ├── Services/        → Protocol + implémentation réseau
    ├── Utilities/       → AppColors, AppStrings, Formatters
    └── Resources/       → Assets, Localizable.xcstrings, banks.json

**Flux de données**

    View
      └── observe → ViewModel (@Observable)
                      └── calls → BankServiceProtocol
                                    └── NetworkBankService
                                          └── Firebase REST API

**Principes appliqués**
- **Protocol-oriented** — `BankServiceProtocol` injectable et mockable
- **Typed throws** — `func fetchBanks() async throws(BankError) -> [Bank]`
- **Value types** — tous les modèles sont des `struct` Codable
- **Type-safe** — `AppColors` et `AppStrings` enums, zéro magic strings
- **Strict Concurrency** — `SWIFT_DEFAULT_ACTOR_ISOLATION = MainActor`

## Stack technique

| Catégorie | Technologie |
|---|---|
| Langage | Swift 6.2 |
| UI | SwiftUI |
| Concurrence | async/await · @Observable |
| Tests | Swift Testing (@Test, #expect) |
| Qualité | SwiftLint + règles custom |
| IDE | Xcode 26.4 |
| IA | Claude Agent (Xcode 26.4) · Claude Code |
| CI/CD | GitHub Actions |
| Versioning | Git Flow · Conventional Commits |

### Choix techniques

- **@Observable** au lieu de `ObservableObject/@Published` — Swift 6.2
- **async/await** au lieu de Combine — plus lisible, recommandé Apple
- **Swift Testing** au lieu de XCTest — framework moderne 2024
- **Typed throws** — `throws(BankError)` pour des erreurs précises
- **SWIFT_APPROACHABLE_CONCURRENCY** — isolation MainActor implicite

## Règles de gestion implémentées

| RG | Description | Statut |
|---|---|---|
| RG00 | Séparation des comptes Crédit Agricole et autres banques | ✅ |
| RG01 | Cellule BankAccount dépliante (collapsible) | ✅ |
| RG02 | Première section : Crédit Agricole — Deuxième section : Autres Banques | ✅ |
| RG03 | Comptes affichés par ordre alphabétique | ✅ |
| RG04 | Dépliage d'une banque → affichage de la liste des comptes | ✅ |
| RG05 | Opérations triées par date décroissante | ✅ |
| RG06 | Même date → tri alphabétique par titre | ✅ |
| RG07 | Navigation retour vers l'écran précédent | ✅ |

> Toutes les règles de gestion sont couvertes par des tests unitaires Swift Testing.

## Git Flow

### Structure des branches

    main (v1.0.0)
      └── develop
            ├── feature/project-setup          → structure MVVM + modèles + couleurs
            ├── feature/swiftlint              → qualité code
            ├── feature/service-layer          → données + localisation + formatters
            ├── feature/tooling                → hooks + CI + Makefile + PR Template
            ├── feature/ci-optimizations       → jobs parallèles + cache + coverage
            ├── feature/RG00-accounts-grouping → séparation CA / autres
            ├── feature/RG01-collapsible       → cellules dépliantes
            ├── feature/RG02-sections          → deux sections
            ├── feature/RG03-sorting           → tri alphabétique
            ├── feature/RG04-accounts-detail   → affichage comptes
            ├── feature/RG05-operations-sorting → tri par date
            ├── feature/RG06-same-date-sorting  → tri alphabétique à égalité
            └── feature/accessibility          → VoiceOver + Dynamic Type + ...

### Tags

| Tag | Description |
|---|---|
| `v1.0.0` | Version finale — toutes les RG implémentées |

### Convention de commits

Format **Conventional Commits** appliqué sur chaque commit :

    feat(RG01): add collapsible bank cells with expand/collapse toggle
    fix(ci): update simulator destination for GitHub Actions
    test(models): add JSON decoding and sorting tests
    chore(tooling): add Makefile, git hooks, CI and PR template
    docs(claude): finalize CLAUDE.md for Claude Agent configuration

### Pull Requests

Chaque branche fait l'objet d'une PR vers `develop` avec :
- Description détaillée des changements
- RG couvertes
- Tests ajoutés
- Screenshots et vidéo démo

## Qualité & Outillage

### SwiftLint

Installé via Swift Package Manager avec des règles custom adaptées au projet :

| Règle | Type | Description |
|---|---|---|
| `no_magic_color_strings` | ❌ Error | Interdit `Color("name")` → utiliser `AppColors` |
| `no_magic_localized_strings` | ❌ Error | Interdit `String(localized:)` → utiliser `AppStrings` |
| `no_observable_object` | ❌ Error | Interdit `ObservableObject` → utiliser `@Observable` |
| `no_published` | ❌ Error | Interdit `@Published` → utiliser `@Observable` |
| `no_dispatch_queue` | ❌ Error | Interdit `DispatchQueue` → utiliser `async/await` |
| `force_unwrapping` | ❌ Error | Interdit le `!` |
| `force_cast` | ❌ Error | Interdit le `as!` |

### Git Hooks (.githooks/)

    pre-commit  → ✅ hook présent
    commit-msg  → vérifie le format Conventional Commits
    pre-push    → ✅ hook présent

### GitHub Actions CI

Déclenché sur chaque PR vers `develop` et `main` :

    Jobs parallèles :
    ├── lint    → SwiftLint (10 min timeout)
    └── test    → xcodebuild test + coverage (45 min timeout)

    Fonctionnalités :
    ├── Cache Homebrew + SwiftLint
    ├── Cache iOS platform
    ├── Code coverage report
    └── Commentaire coverage automatique sur la PR

### Makefile

    make lint     → lance SwiftLint
    make test     → lance xcodebuild test avec coverage
    make coverage → extrait le taux de couverture
    make clean    → nettoie DerivedData

### CLAUDE.md

Fichier de configuration pour Claude Agent — définit l'architecture,
les règles de code, le Git Flow et la politique de tests.
Claude Agent lit ce fichier au démarrage de chaque session.

## Accessibilité

L'accessibilité a été traitée comme une feature à part entière,
pas comme un ajout de dernière minute.

### Fonctionnalités accessibilité implémentées

- **VoiceOver** — labels, hints, values sur tous les éléments interactifs
- **Rotor** — navigation par Titres, Boutons et Éléments
- **Dynamic Type** — `ViewThatFits` adapte le layout à toutes les tailles
- **Dark Mode** — couleurs sémantiques via `AppColors`, adaptation automatique
- **Reduce Motion** — animations conditionnelles via `@Environment(\.accessibilityReduceMotion)`
- **Differentiate Without Color** — montants négatifs en **gras** sans rouge
- **Increase Contrast** — ratio ≥ 4.5:1 sur tous les textes
- **Dates VoiceOver** — format long "14 février 2022" au lieu de "14/02/2022"
- **Montants négatifs** — annoncés "moins 15,99 euros" au lieu de "-15,99"

### Tests d'accessibilité

    performAccessibilityAudit() — audit automatique à chaque CI
    Filtres : contraste système uniquement (faux positifs connus)
    Audits : elementDetection, hitRegion, sufficientElementDescription,
             dynamicType, textClipped, trait, action

### Tests manuels effectués

- ✅ VoiceOver sur iPhone réel (FR)
- ✅ Rotor — Titres, Boutons, Éléments
- ✅ Dynamic Type AX5 (taille maximale)
- ✅ Dark Mode
- ✅ Increase Contrast
- ✅ Reduce Motion
- ✅ Differentiate Without Color
- ✅ Accessibility Inspector — 0 erreur sur le code custom

## Tests

### Résumé

    Total    : 78 tests — 78 ✅ — 0 ❌ — 0 ⏭️
    Framework : Swift Testing (@Test, #expect)
    UI Tests  : XCTest + performAccessibilityAudit()

### Organisation des suites

    BankAppTests/ (75 tests)
    ├── BankModelTests
    │     ├── IsCreditAgricole        → 4 tests  (RG00)
    │     ├── Timestamp               → 3 tests
    │     ├── FormattedDate           → 1 test
    │     ├── AccessibilityDate       → 2 tests
    │     ├── SortedOperations        → 6 tests  (RG05)
    │     ├── SortedOperationsRG06    → 7 tests  (RG06)
    │     ├── IsNegativeBalance       → 3 tests
    │     ├── AccessibilityAmount     → 3 tests
    │     └── IsNegative              → 3 tests
    │
    ├── AccountsViewModelTests
    │     ├── Grouping                → 3 tests  (RG00)
    │     ├── FetchState              → 3 tests
    │     ├── ExpandCollapse          → 3 tests  (RG01)
    │     ├── Sections                → 2 tests  (RG02)
    │     ├── Sorting                 → 8 tests  (RG03)
    │     ├── AccountDetails          → 9 tests  (RG04)
    │     └── (Loading State)         → 3 tests
    │
    ├── OperationsViewModelTests
    │     ├── Delegation              → 1 test
    │     └── AccountProperties       → 4 tests
    │
    ├── FormattersTests
    │     ├── StringCurrency          → 4 tests
    │     ├── DoubleCurrency          → 4 tests
    │     └── DateFormat              → 1 test
    │
    └── ServiceTests                  → 2 tests

    BankAppUITests/ (3 tests)
    └── AccessibilityAuditTests
          └── testAccountsListAccessibility() → performAccessibilityAudit()

### Couverture

| Couche | Fichier | Coverage |
|---|---|---|
| Models | Bank.swift | 100% |
| ViewModels | AccountsViewModel.swift | 97.6% |
| ViewModels | OperationsViewModel.swift | 100% |
| Services | NetworkBankService.swift | 80% |
| Utilities | Formatters.swift | 95.5% |
| Utilities | AppColors.swift | 100% |
| Views | AccountsListView, OperationsView, AccountRowView | — |

> Les Views ne sont pas couvertes par les tests unitaires —
> c'est intentionnel. Elles sont validées par `performAccessibilityAudit()`
> et les tests manuels VoiceOver / Dynamic Type documentés ci-dessus.

**Coverage Models + ViewModels : 97%+**

## Utilisation de l'IA

**Claude Agent** (Xcode 26.4) a été intégré au workflow via un fichier
`CLAUDE.md` à la racine du projet — il définit les conventions :
architecture MVVM, règles SwiftLint, Git Flow, politique de tests
et langue des commentaires. Ce fichier est lu par Claude Agent
au démarrage de chaque session pour garantir la cohérence du code.

Des Git Hooks ont également été configurés pour encadrer les suggestions :
le hook `commit-msg` vérifie le format Conventional Commits avant
chaque commit, bloquant toute contribution non conforme.

Claude Agent a été utilisé ponctuellement pour accélérer certaines
tâches répétitives : génération de boilerplate, suggestions de tests
et audit de code.

Chaque fichier généré a été relu, corrigé et validé (Cmd+B + Cmd+U)
avant intégration.

## Note sur l'architecture réseau

L'API Firebase fournie retourne un tableau `[Bank]` directement —
pas un objet enveloppé. Le décodage s'adapte à cette structure :

    let banks = try JSONDecoder().decode([Bank].self, from: data)

### Gestion des erreurs réseau

En cas d'échec de l'appel Firebase, l'app affiche un message clair
à l'utilisateur avec la possibilité de réessayer via **pull to refresh**.

    ✅ Réseau OK  → données Firebase affichées
    ❌ Réseau KO  → message d'erreur + pull to refresh

### Anomalie détectée dans les données

Lors de l'analyse du JSON, une anomalie a été identifiée :
plusieurs opérations partagent le même `id` au sein d'un même compte.

Par exemple dans le compte Banque Pop :

    { "id": "2", "title": "Prêt immo" }
    { "id": "2", "title": "CB La Vie Claire" }

SwiftUI utilisant l'`id` pour identifier les cellules,
ce doublon provoquait l'affichage d'une seule opération sur deux.

**Correction appliquée** — `BankOperation` génère un `UUID` local
à chaque décodage, indépendamment de l'`id` serveur :

    var id: UUID = UUID()            // identifiant SwiftUI unique
    var operationId: String          // id original du JSON conservé

> Cette anomalie semble être une limitation des données de test
> et non un comportement attendu en production.

## Comment lancer le projet

### Prérequis

- Xcode 26.4+
- iOS 17.0+
- Swift 6.2
- Homebrew (pour SwiftLint)

### Installation

    # 1. Cloner le repo
    git clone https://github.com/obarhdad/test_entretien_cats.git
    cd test_entretien_cats

    # 2. Installer SwiftLint
    brew install swiftlint

    # 3. Configurer les Git Hooks
    git config core.hooksPath .githooks

    # 4. Ouvrir le projet
    open BankApp/BankApp.xcodeproj

### Lancer l'app

    Cmd+R → lance l'app sur le simulateur

### Lancer les tests

    Cmd+U → lance tous les tests
    
    # Ou via Makefile
    make test     → tests avec coverage
    make lint     → SwiftLint
    make coverage → taux de couverture

### Source de données

L'app récupère les données depuis :

    https://cdf-test-mobile-default-rtdb.europe-west1.firebasedatabase.app/banks.json

En cas d'indisponibilité → pull to refresh pour réessayer.

## Auteur

**Ahmed Ouledzian**
