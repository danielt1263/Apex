//
//  Store.swift
//  Apex
//
//  Created by Daniel Tartaglia on 01/16/15.
//  Copyright © 2017 Daniel Tartaglia. MIT License.
//


public protocol Action { }

public protocol State {
	mutating func transition(using: Action)
}

public typealias Dispatcher = (Action) -> Void

public final class Store {

	public typealias Observer = (State) -> Void

	public init(state: State) {
		self.state = state
	}

	public func dispatch(action: Action) {
		guard !isDispatching else { fatalError("Cannot dispatch in the middle of a dispatch") }
		isDispatching = true
		state.transition(using: action)
		for subscriber in subscribers.values {
			subscriber(state)
		}
		isDispatching = false
	}

	public func subscribe(observer: @escaping Observer) -> Unsubscriber {
		let id = UUID()
		subscribers[id] = { state in observer(state) }
		let dispose = { [weak self] () -> Void in
			let _ = self?.subscribers.removeValue(forKey: id)
		}
		observer(state)
		return Unsubscriber(method: dispose)
	}

	private var state: State
	private var isDispatching = false
	private var subscribers: [UUID: Observer] = [:]
}

public final class Unsubscriber {
	private var method: (() -> Void)?

	fileprivate init(method: @escaping () -> Void) {
		self.method = method
	}

	deinit {
		unsubscribe()
	}

	public func unsubscribe() {
		if let method = method {
			method()
		}
		method = nil
	}
}
