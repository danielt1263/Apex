//
//  Store.swift
//  Apex
//
//  Created by Daniel Tartaglia on 01/16/15.
//  Copyright © 2017 Daniel Tartaglia. MIT License.
//


public
protocol Action { }

public
protocol Dispatcher {
	func dispatch(action: Action)
}

public
protocol Publisher {
	associatedtype State
	typealias Observer = (State) -> Void
	func subscribe(observer: @escaping Observer) -> Unsubscriber
}

public
protocol State {
	mutating func transition(_ action: Action)
}

public final
class Store<S: State>: Dispatcher, Publisher {

	public typealias State = S
	public typealias Logger = (S, Action) -> Void

	public init(initial: (State, [Command]), update: @escaping (State, Action) -> (State, [Command]), loggers: [Logger] = []) {
		self.state = initial.0
		self.update = update
		self.loggers = loggers
		for command in initial.1 {
			command.execute(self.dispatch)
		}
	}

	public func dispatch(action: Action) -> Void {
		let result = update(state, action)
		state = result.0

		DispatchQueue.main.async {
			guard !self.isDispatching else { fatalError("Cannot dispatch in the middle of a dispatch") }
			self.isDispatching = true
			for logger in self.loggers {
				logger(self.state, action)
			}
			for subscriber in self.subscribers.values {
				subscriber(self.state)
			}
			self.isDispatching = false
			for command in result.1 {
				command.execute(self.dispatch)
			}
		}
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

	private let queue = DispatchQueue(label: "store")
	private let update: (State, Action) -> (State, [Command])
	private let loggers: [Logger]
	private var state: S
	private var isDispatching = false
	private var subscribers: [UUID: Observer] = [:]
}

public final
class Unsubscriber {
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
