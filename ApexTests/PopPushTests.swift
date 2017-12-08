//
//  PopPushTests.swift
//  Apex
//
//  Created by Daniel Tartaglia on 3/18/17.
//  Copyright © 2017 Daniel Tartaglia. All rights reserved.
//

import XCTest
@testable import Apex


struct PushPopResult: Equatable {
	let id: String
	let isLast: Bool

	static func ==(lhs: PushPopResult, rhs: PushPopResult) -> Bool {
		return lhs.id == rhs.id && lhs.isLast == rhs.isLast
	}
}

final
class PopPushTests: XCTestCase {

	override func setUp() {
		super.setUp()
		popped = []
		pushed = []
	}
	
	var popped: [PushPopResult] = []
	func pop(s: String, isLast: Bool) { popped.append(PushPopResult(id: s, isLast: isLast)) }
	var pushed: [PushPopResult] = []
	func push(s: String, isLast: Bool) { pushed.append(PushPopResult(id: s, isLast: isLast)) }
	
	func testPushOne() {
		let array1: [String] = []
		let array2: [String] = ["first"]
		
		popPush(current: array1, target: array2, pop: pop, push: push)
		
		XCTAssertEqual(popped, [])
		XCTAssertEqual(pushed, [PushPopResult(id: "first", isLast: true)])
	}

	func testPopOne() {
		let array1: [String] = ["first"]
		let array2: [String] = []
		
		popPush(current: array1, target: array2, pop: pop, push: push)
		
		XCTAssertEqual(popped, [PushPopResult(id: "first", isLast: true)])
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
		
		XCTAssertEqual(popped, [PushPopResult(id: "first", isLast: false)])
		XCTAssertEqual(pushed, [PushPopResult(id: "second", isLast: true)])
	}

	func testPushTwo() {
		let array1: [String] = []
		let array2: [String] = ["first", "second"]
		
		popPush(current: array1, target: array2, pop: pop, push: push)
		
		XCTAssertEqual(popped, [])
		XCTAssertEqual(pushed, [PushPopResult(id: "first", isLast: false), PushPopResult(id: "second", isLast: true)])
	}
	
	func testPopTwo() {
		let array1: [String] = ["first", "second"]
		let array2: [String] = []
		
		popPush(current: array1, target: array2, pop: pop, push: push)
		
		XCTAssertEqual(popped, [PushPopResult(id: "second", isLast: false), PushPopResult(id: "first", isLast: true)])
		XCTAssertEqual(pushed, [])
	}
	
	func testPopSecond() {
		let array1: [String] = ["first", "second"]
		let array2: [String] = ["first"]
		
		popPush(current: array1, target: array2, pop: pop, push: push)
		
		XCTAssertEqual(popped, [PushPopResult(id: "second", isLast: true)])
		XCTAssertEqual(pushed, [])
	}
	
	func testPushSecond() {
		let array1: [String] = ["first"]
		let array2: [String] = ["first", "second"]
		
		popPush(current: array1, target: array2, pop: pop, push: push)
		
		XCTAssertEqual(popped, [])
		XCTAssertEqual(pushed, [PushPopResult(id: "second", isLast: true)])
	}
	
}
