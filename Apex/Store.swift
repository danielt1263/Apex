//
//  Store.swift
//  Apex
//
//  Created by Daniel Tartaglia on 01/16/15.
//  Copyright © 2017 Daniel Tartaglia. MIT License.
//


public protocol Action { }

public typealias Dispatcher = (Action) -> Void

public final class Store<State> {

	public typealias Reducer = (State, Action) -> State
	public typealias Observer = (State) -> Void
	public typealias Middleware = (_ dispatcher: @escaping Dispatcher, _ state: @autoclosure @escaping () -> State, _ next: @escaping Dispatcher) -> Dispatcher

	public init(state: State, reducer: @escaping Reducer, middleware: [Middleware] = []) {
		self.state = state
		reduce = reducer
		dispatcher = middleware.reversed().reduce(self._dispatch) { result, middleware in
			return middleware(self.dispatch, self.state, result)
		}
	}

	public func dispatch(action: Action) {
		self.dispatcher(action)
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
	private let reduce: Reducer
	private var isDispatching = false
	private var subscribers: [UUID: Observer] = [:]
	private var dispatcher: Dispatcher = { _ in fatalError() }

	private func _dispatch(action: Action) {
		guard !isDispatching else { fatalError("Cannot dispatch in the middle of a dispatch") }
		isDispatching = true
		state = reduce(state, action)
		for subscriber in subscribers.values {
			subscriber(state)
		}
		isDispatching = false
	}

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
