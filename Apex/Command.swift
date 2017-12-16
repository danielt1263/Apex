//
//  Command.swift
//  Apex
//
//  Created by Daniel Tartaglia on 11/27/17.
//  Copyright © 2017 Daniel Tartaglia. All rights reserved.
//

import Foundation

public
protocol Command: Equatable {
	associatedtype Action
	func execute<D>(dispatcher: D) where D: Dispatcher, D.Action == Action
}

final class AnyCommand<A>: Command {

	typealias Action = A

	init<C>(_ command: C) where C: Command, C.Action == Action {
		value = command
		_execute = { command.execute(dispatcher: $0) }
		isEqual = {
			guard let other = $0.value as? C else { return false }
			return command == other
		}
	}

	func execute<D>(dispatcher: D) where D : Dispatcher, A == D.Action {
		_execute(AnyDispatcher(dispatcher))
	}

	static func ==(lhs: AnyCommand<A>, rhs: AnyCommand<A>) -> Bool {
		return lhs.isEqual(rhs)
	}

	private let value: Any
	private let _execute: (AnyDispatcher<A>) -> Void
	private let isEqual: (AnyCommand) -> Bool
}
