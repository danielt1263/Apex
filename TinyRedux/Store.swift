//
//  Store.swift
//  TinyRedux
//
//  Created by Daniel Tartaglia on 01/16/15.
//  Copyright © 2017 Daniel Tartaglia. MIT License.
//


public protocol Event { }

public final class Store<State> {

	public typealias Reducer = (State, Event) -> State
	public typealias Observer = (State) -> Void
	public typealias Dispatcher = (Event) -> Void
	public typealias Middleware = (_ state: State, _ next: @escaping Dispatcher) -> Dispatcher

	public init(state: State, reducer: @escaping Reducer, middleware: [Middleware] = []) {
		self.state = state
		reduce = reducer
		dispatcher = middleware.reversed().reduce(self._dispatch) { result, middleware -> Dispatcher in
			return middleware(self.state, result)
		}
	}

	public func dispatch(event: Event) {
		self.dispatcher(event)
	}

	public func subscribe(observer: @escaping Observer) -> Unsubscriber {
		return subscribe(observer: observer, lens: { $0 })
	}

	public func subscribe<T>(observer: @escaping (T) -> Void, lens: @escaping (State) -> T) -> Unsubscriber {
		let id = UUID()
		subscribers[id] = { state in observer(lens(state)) }
		let dispose = { [weak self] () -> Void in
			let _ = self?.subscribers.removeValue(forKey: id)
		}
		observer(lens(state))
		return Unsubscriber(method: dispose)
	}

	private var state: State
	private let reduce: Reducer
	private var isDispatching = false
	private var subscribers: [UUID: Observer] = [:]
	private var dispatcher: Dispatcher = { _ in fatalError() }

	private func _dispatch(event: Event) {
		guard !isDispatching else { fatalError("Cannot dispatch in the middle of a dispatch") }
		isDispatching = true
		state = reduce(state, event)
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
