//
//  Subscription.swift
//  Apex
//
//  Created by Daniel Tartaglia on 12/16/17.
//  Copyright © 2017 Daniel Tartaglia. All rights reserved.
//

import Foundation

public
protocol Subscription {
	associatedtype Action
	func launch<D>(dispatcher: D) where D: Dispatcher, D.Action == Action
	func cancel()
}

final class AnySubscription<A>: Subscription {

	typealias Action = A

	init<S>(_ subscription: S) where S: Subscription, S.Action == Action {
		_launch = { subscription.launch(dispatcher: $0) }
		_cancel = subscription.cancel
	}

	func launch<D>(dispatcher: D) where D : Dispatcher, A == D.Action {
		_launch(AnyDispatcher<Action>(dispatcher))
	}

	func cancel() {
		_cancel()
	}

	private let _launch: (AnyDispatcher<A>) -> Void
	private let _cancel: () -> Void
}
