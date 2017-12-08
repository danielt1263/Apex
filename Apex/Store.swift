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

public final
class Store<S>: Dispatcher, Publisher {

	public typealias State = S

	public init(initial: (State, [Command]), update: @escaping (State, Action) -> (State, [Command])) {
		self.state = initial.0
		self.update = update
		for command in initial.1 {
			command.execute(self)
		}
	}

	public func dispatch(action: Action) -> Void {
		queue.async {
			let result = self.update(self.state, action)
			self.state = result.0

			DispatchQueue.main.async {
				for subscriber in self.subscribers.values {
					subscriber(self.state)
				}
				for command in result.1 {
					command.execute(self)
				}
			}
		}
	}

	public func subscribe(observer: @escaping Observer) -> Unsubscriber {
		let id = UUID()
		subscribers[id] = { state in observer(state) }
		let dispose = { [weak self] () -> Void in
			self?.subscribers.removeValue(forKey: id)
		}
		observer(state)
		return Unsubscriber(method: dispose)
	}

	private let queue = DispatchQueue(label: "Apex")
	private let update: (State, Action) -> (State, [Command])
	private var state: State
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
