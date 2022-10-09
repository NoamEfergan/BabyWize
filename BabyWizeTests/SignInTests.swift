//
//  SignInTests.swift
//  BabyWizeTests
//
//  Created by Noam Efergan on 17/09/2022.
//

@testable import BabyWize
import XCTest

final class SignInTests: XCTestCase {
    let vm: AuthViewModel

    override func setUpWithError() throws {
        vm = .init()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func test_email_verification() {
        let validEmail = "1@2.com"
        let invalidEmail = "asdf"
        XCTAssertTrue(vm.validateEmail(validEmail))
        XCTAssertFalse(vm.validateEmail(invalidEmail))
    }
    
    func test_password_validation() {
        XCTAssertFalse(vm.validatePassword("1234"))
        XCTAssertFalse(vm.validatePassword("test"))
        XCTAssertFalse(vm.validatePassword("Tesst1234"))
    }
}
