//
//  ApexTests.swift
//  ApexTests
//
//  Created by Daniel Tartaglia on 3/15/17.
//  Copyright © 2017 Daniel Tartaglia. MIT License.
//

import XCTest
@testable import Apex

final
class ApexTests: XCTestCase {

	func testInitialCommandExecution() {
		weak var expect = expectation(description: "Example")
		_ = Store<TestState>(initial: (TestState(), [testCommand(expect)]), update: { state, _ in
			return (state, [])
		})
		waitForExpectations(timeout: 1, handler: nil)
	}

	func testCommandExecution() {
		weak var expect = expectation(description: "Example")
		let store = Store<TestState>(initial: (TestState(), []), update: { state, _ in
			return (state, [testCommand(expect)])
		})
		store.dispatch(action: TestAction.test)
		waitForExpectations(timeout: 1, handler: nil)
	}
}

enum TestAction: Action {
	case test
}

struct TestState { }

func testCommand(_ expect: XCTestExpectation?) -> BlockCommand {
	return BlockCommand(description: "Test Command") { dispatch in
		expect?.fulfill()
	}
}
