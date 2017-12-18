//
//  BlockCommand.swift
//  Apex
//
//  Created by Daniel Tartaglia on 12/18/17.
//  Copyright © 2017 Daniel Tartaglia. All rights reserved.
//

public final
class BlockCommand: Command, Equatable, CustomStringConvertible {

	public let description: String

	init(description: String, work: @escaping (Dispatcher) -> Void) {
		self.description = description
		self.work = work
	}

	public
	func execute(dispatcher: Dispatcher) {
		work(dispatcher)
	}

	public
	static func ==(lhs: BlockCommand, rhs: BlockCommand) -> Bool {
		return lhs.description == rhs.description
	}

	private let work: (Dispatcher) -> Void
}
