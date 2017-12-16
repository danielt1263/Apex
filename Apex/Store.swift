//
//  Store.swift
//  Apex
//
//  Created by Daniel Tartaglia on 01/16/15.
//  Copyright © 2017 Daniel Tartaglia. MIT License.
//


public
protocol Publisher {
	associatedtype State
	typealias Observer = (State) -> Void
	func subscribe(observer: @escaping Observer) -> Unsubscriber
}

public final
class Store<S, A>: Dispatcher, Publisher {

	public typealias Action = A
	public typealias State = S

	public init<C>(initial: (State, [C]), update: @escaping (State, Action) -> (State, [C])) where C: Command, C.Action == Action {
		self.state = initial.0
		self.update = { state, message in
			let (s, cs) = update(state, message)
			return (s, cs.map { AnyCommand($0) })
		}
		for command in initial.1 {
			command.execute(dispatcher: self)
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
					command.execute(dispatcher: self)
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
	private let update: (State, Action) -> (State, [AnyCommand<Action>])
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
