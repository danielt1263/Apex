//
//  CommandComponent.swift
//  Apex
//
//  Created by Daniel Tartaglia on 7/22/17.
//  Copyright © 2017 Daniel Tartaglia. MIT License.
//

import Foundation

public protocol Command: Hashable {
	func cancel()
	func launch(dispatcher: Dispatcher)
}

public final class CommandComponent<C: Command> {
	
	public typealias Commands = Set<C>
	
	public init<S: State>(store: Store<S>, lens: @escaping (S) -> Commands) {
		self.dispatcher = store
		unsubscriber = store.subscribe { [weak self] state in
			let commands = lens(state)
			self?.configure(using: commands)
		}
	}
	
	private let dispatcher: Dispatcher
	private var unsubscriber: Unsubscriber?
	private var inFlight: Commands = Set()
	
	private func configure(using target: Commands) {
		cancelLaunch(current: inFlight, target: target, cancel: { $0.cancel() }, launch: { $0.launch(dispatcher: dispatcher) })
		inFlight = target
	}
}

public func cancelLaunch<T>(current: Set<T>, target: Set<T>, cancel: (T) -> Void, launch: (T) -> Void) {
	for each in current.subtracting(target) {
		cancel(each)
	}
	for each in target.subtracting(current) {
		launch(each)
	}
}

public struct AnyCommand: Command {
	
	public init<C: Command>(_ base: C) {
		self.base = base
		self._hashValue = { base.hashValue }
		self._equals = {
			if let other = $0 as? C {
				return base == other
			}
			return false
		}
		self._cancel = base.cancel
		self._launch = base.launch
	}
	
	public var hashValue: Int { return _hashValue() }
	
	public func cancel() {
		_cancel()
	}
	
	public func launch(dispatcher: Dispatcher) {
		_launch(dispatcher)
	}
	
	public static func ==(lhs: AnyCommand, rhs: AnyCommand) -> Bool {
		return lhs._equals(rhs.base)
	}
	
	private let base: Any
	private let _hashValue: () -> Int
	private let _equals: (Any) -> Bool
	private let _cancel: () -> Void
	private let _launch: (Dispatcher) -> Void
}
