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
protocol Publisher {
	associatedtype State
	typealias Observer = (State) -> Void
	func observe(observer: @escaping Observer) -> Unobserver
}

public final
class Store<S>: Dispatcher, Publisher {

	public typealias State = S

	public init(initial: (State, [Command]), update: @escaping (State, Action) -> (State, [Command]), subscriptions: @escaping (State) -> Set<AnySubscription>) {
		self.state = initial.0
		self.update = update
		self.subscriptions = subscriptions
		for command in initial.1 {
			command.execute(dispatcher: self)
		}
	}

	public func dispatch(action: Action) -> Void {
		queue.async {
			let result = self.update(self.state, action)
			self.state = result.0

			DispatchQueue.main.async {
				for subscriber in self.observers.values {
					subscriber(self.state)
				}
				let subscribers = self.subscriptions(self.state)
				for each in self.inFlight.subtracting(subscribers) {
					each.cancel()
					self.inFlight.remove(each)
				}
				for each in subscribers.subtracting(self.inFlight) {
					self.inFlight.insert(each)
					each.launch(dispatcher: self)
				}
				for command in result.1 {
					command.execute(dispatcher: self)
				}
			}
		}
	}

	public func observe(observer: @escaping Observer) -> Unobserver {
		let id = UUID()
		observers[id] = { state in observer(state) }
		let dispose = { [weak self] () -> Void in
			self?.observers.removeValue(forKey: id)
		}
		observer(state)
		return Unobserver(method: dispose)
	}

	private let queue = DispatchQueue(label: "Apex")
	private let update: (State, Action) -> (State, [Command])
	private let subscriptions: (State) -> Set<AnySubscription>
	private var state: State
	private var inFlight: Set<AnySubscription> = []
	private var observers: [UUID: Observer] = [:]
}

public final
class Unobserver {
	private var method: (() -> Void)?

	fileprivate init(method: @escaping () -> Void) {
		self.method = method
	}

	deinit {
		unobserve()
	}

	public func unobserve() {
		if let method = method {
			method()
		}
		method = nil
	}
}
