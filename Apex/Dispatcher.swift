//
//  Dispatcher.swift
//  Apex
//
//  Created by Daniel Tartaglia on 12/16/17.
//  Copyright © 2017 Daniel Tartaglia. All rights reserved.
//

import Foundation

public
protocol Dispatcher {
	associatedtype Action
	func dispatch(action: Action)
}

final class AnyDispatcher<A>: Dispatcher {
	typealias Action = A

	init<D>(_ dispatcher: D) where D: Dispatcher, D.Action == Action {
		_dispatch = dispatcher.dispatch
	}

	func dispatch(action: Action) {
		_dispatch(action)
	}

	let _dispatch: (Action) -> ()
}
