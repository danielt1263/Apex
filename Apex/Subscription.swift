//
//  Subscription.swift
//  Apex
//
//  Created by Daniel Tartaglia on 12/16/17.
//  Copyright © 2017 Daniel Tartaglia. MIT License
//



public
protocol Subscription: Hashable {
	func launch(dispatcher: Dispatcher)
	func cancel()
}

public final
class AnySubscription: Subscription {

	public
	convenience init<S: Subscription>(_ subscription: S) {
		self.init(launch: subscription.launch, cancel: subscription.cancel, rep: subscription)
	}

	public
	init<H: Hashable>(launch: @escaping (Dispatcher) -> Void, cancel: @escaping () -> Void, rep: H) {
		_launch = launch
		_cancel = cancel
		_equals = { $0 as? H == rep }
		self.rep = rep
	}

	public
	func launch(dispatcher: Dispatcher) {
		_launch(dispatcher)
	}

	public
	func cancel() {
		_cancel()
	}

	public
	var hashValue: Int { return rep.hashValue }

	public
	static func ==(lhs: AnySubscription, rhs: AnySubscription) -> Bool {
		return lhs._equals(rhs.rep)
	}

	private let _launch: (Dispatcher) -> Void
	private let _cancel: () -> Void
	private let _equals: (AnyHashable) -> Bool
	private let rep: AnyHashable
}
