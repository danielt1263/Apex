//
//  Store.swift
//  Apex
//
//  Created by Daniel Tartaglia on 01/16/15.
//  Copyright © 2017 Daniel Tartaglia. MIT License.
//


public protocol Action { }

public protocol State {
	mutating func transition(dueTo: Action)
}

public typealias Dispatcher = (Action) -> Void
public typealias Logger = (_ pre: State, _ action: Action, _ post: State) -> Void
public typealias Observer = (State) -> Void

public final class Store {

	public init(state: State, logger: Logger? = nil) {
		self.log = logger
		self.state = state
	}

	public func dispatch(action: Action) {
		guard !isDispatching else { fatalError("Cannot dispatch in the middle of a dispatch") }
		isDispatching = true
		let pre = state
		state.transition(dueTo: action)
		let post = state
		log?(pre, action, post)
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
	private let log: Logger?
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
