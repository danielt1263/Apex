//
//  Store.swift
//  TinyRedux
//
//  Created by Daniel Tartaglia on 01/16/15.
//  Copyright © 2017 Daniel Tartaglia. MIT License.
//


public final class Store<State, Action>: ObservableStore {

	public typealias Reducer = (State, Action) -> State
	public typealias Observer = (State) -> Void
	public typealias Dispatcher = (Action) -> Void
	public typealias Middleware = (@escaping Dispatcher, @escaping () -> State) -> Dispatcher

	public init(state: State, reducer: @escaping Reducer, middleware: [Middleware] = []) {
		self.state = state
		reduce = reducer
		dispatcher = middleware.reversed().reduce(self._dispatch) { (dispatcher: @escaping Dispatcher, middleware: Middleware) -> Dispatcher in
			middleware(dispatcher, { self.state })
		}
	}

	public func dispatch(action: Action) {
		guard !isDispatching else { fatalError("Cannot dispatch in the middle of a dispatch") }
		isDispatching = true
		self.dispatcher(action)
		isDispatching = false
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

	private func _dispatch(action: Action) {
		state = reduce(state, action)
		for subscriber in subscribers.values {
			subscriber(state)
		}
	}

	private let reduce: Reducer
	private var state: State
	private var isDispatching = false
	private var subscribers: [UUID: Observer] = [:]
	private var dispatcher: Dispatcher = { _ in fatalError() }
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
