//
//  PushPopExpress.swift
//  ApexTests
//
//  Created by Daniel Tartaglia on 9/30/17.
//  Copyright © 2017 Daniel Tartaglia. All rights reserved.
//

import XCTest
@testable import Apex

final
class PushPopExpress: XCTestCase {
    
	override func setUp() {
		super.setUp()
		popped = nil
		pushed = []
	}
	
	var popped: (i: Int, isLast: Bool)?
	func pop(i: Int, isLast: Bool) { popped = (i: i, isLast: isLast) }
	var pushed: [PushPopResult] = []
	func push(s: String, isLast: Bool) { pushed.append(PushPopResult(id: s, isLast: isLast)) }
	
	func testPushOne() {
		let array1: [String] = ["a"]
		let array2: [String] = ["a", "b"]
		
		popPushExpress(current: array1, target: array2, popTo: pop, push: push)
		
		XCTAssertEqual(popped?.i, nil)
		XCTAssertEqual(pushed, [PushPopResult(id: "b", isLast: true)])
	}
	
	func testDoNothingWithOne() {
		let array1: [String] = ["a"]
		let array2: [String] = ["a"]
		
		popPushExpress(current: array1, target: array2, popTo: pop, push: push)

		XCTAssertEqual(popped?.i, nil)
		XCTAssertEqual(pushed, [])
	}

	func testPopOne() {
		let array1: [String] = ["a", "b"]
		let array2: [String] = ["a"]
		
		popPushExpress(current: array1, target: array2, popTo: pop, push: push)
		
		XCTAssertEqual(popped?.i, 0)
		XCTAssertEqual(popped?.isLast, true)
		XCTAssertEqual(pushed, [])
	}
	
	func testPopPush() {
		let array1: [String] = ["a", "b"]
		let array2: [String] = ["a", "c"]
		
		popPushExpress(current: array1, target: array2, popTo: pop, push: push)
		
		XCTAssertEqual(popped?.i, 0)
		XCTAssertEqual(popped?.isLast, false)
		XCTAssertEqual(pushed, [PushPopResult(id: "c", isLast: true)])
	}
	
	func testPushTwo() {
		let array1: [String] = ["a"]
		let array2: [String] = ["a", "b", "c"]
		
		popPushExpress(current: array1, target: array2, popTo: pop, push: push)

		XCTAssertEqual(popped?.i, nil)
		XCTAssertEqual(pushed, [PushPopResult(id: "b", isLast: false), PushPopResult(id: "c", isLast: true)])
	}
	
	func testPopTwo() {
		let array1: [String] = ["a", "b", "c"]
		let array2: [String] = ["a"]
		
		popPushExpress(current: array1, target: array2, popTo: pop, push: push)
		
		XCTAssertEqual(popped?.i, 0)
		XCTAssertEqual(popped?.isLast, true)
		XCTAssertEqual(pushed, [])
	}

}
