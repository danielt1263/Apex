//
//  PopPushTests.swift
//  TinyRedux
//
//  Created by Daniel Tartaglia on 3/18/17.
//  Copyright © 2017 Daniel Tartaglia. All rights reserved.
//

import XCTest
@testable import TinyRedux


class PopPushTests: XCTestCase {

	override func setUp() {
		super.setUp()
		popped = []
		pushed = []
	}
	
	var popped: [String] = []
	func pop(s: String) { popped.append(s) }
	var pushed: [String] = []
	func push(s: String) { pushed.append(s) }
	
	func testPushOne() {
		let array1: [String] = []
		let array2: [String] = ["first"]
		
		popPush(current: array1, target: array2, pop: pop, push: push)
		
		XCTAssertEqual(popped, [])
		XCTAssertEqual(pushed, array2)
	}

	func testPopOne() {
		let array1: [String] = ["first"]
		let array2: [String] = []
		
		popPush(current: array1, target: array2, pop: pop, push: push)
		
		XCTAssertEqual(popped, ["first"])
		XCTAssertEqual(pushed, [])
	}

	func testDoNothingWithOne() {
		let array1: [String] = ["first"]
		let array2: [String] = ["first"]
		
		popPush(current: array1, target: array2, pop: pop, push: push)
		
		XCTAssertEqual(popped, [])
		XCTAssertEqual(pushed, [])
	}
	
	func testPopPush() {
		let array1: [String] = ["first"]
		let array2: [String] = ["second"]
		
		popPush(current: array1, target: array2, pop: pop, push: push)
		
		XCTAssertEqual(popped, ["first"])
		XCTAssertEqual(pushed, ["second"])
	}

	func testPushTwo() {
		let array1: [String] = []
		let array2: [String] = ["first", "second"]
		
		popPush(current: array1, target: array2, pop: pop, push: push)
		
		XCTAssertEqual(popped, [])
		XCTAssertEqual(pushed, ["first", "second"])
	}
	
	func testPopTwo() {
		let array1: [String] = ["first", "second"]
		let array2: [String] = []
		
		popPush(current: array1, target: array2, pop: pop, push: push)
		
		XCTAssertEqual(popped, ["second", "first"])
		XCTAssertEqual(pushed, array2)
	}
	
	func testPopSecond() {
		let array1: [String] = ["first", "second"]
		let array2: [String] = ["first"]
		
		popPush(current: array1, target: array2, pop: pop, push: push)
		
		XCTAssertEqual(popped, ["second"])
		XCTAssertEqual(pushed, [])
	}
	
	func testPushSecond() {
		let array1: [String] = ["first"]
		let array2: [String] = ["first", "second"]
		
		popPush(current: array1, target: array2, pop: pop, push: push)
		
		XCTAssertEqual(popped, [])
		XCTAssertEqual(pushed, ["second"])
	}
	
}
