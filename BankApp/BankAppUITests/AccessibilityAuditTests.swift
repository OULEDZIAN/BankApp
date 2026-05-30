//
//  AccessibilityAuditTests.swift
//  BankAppUITests
//
//  Created by AOZ on 30/05/2026.
//

import XCTest

final class AccessibilityAuditTests: XCTestCase {
    func testAccountsListAccessibility() throws {
        let app = XCUIApplication()
        app.launch()
        try app.performAccessibilityAudit { issue in
            issue.auditType == .contrast
        }
    }
}
