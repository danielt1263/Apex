//
//  SubscriptionComponent.swift
//  Apex
//
//  Created by Daniel Tartaglia on 7/22/17.
//  Copyright © 2017 Daniel Tartaglia. MIT License.
//

import Foundation


public
protocol Subscription {
	func launch(dispatcher: Dispatcher)
	func cancel()
}

public final
class SubscriptionComponent<Request: Hashable> {
	public typealias Requests = Set<Request>
	
	public init<S>(store: Store<S>, lens: @escaping (S) -> Requests, commandFactory: @escaping (Request) -> Subscription) {
		dispatcher = store
		createSubscription = commandFactory
		unsubscriber = store.subscribe(observer: { [weak self] state in
			self?.configure(using: lens(state))
		})
	}

	private let dispatcher: Dispatcher
	private let createSubscription: (Request) -> Subscription
	private var unsubscriber: Unsubscriber?
	private var inFlight: [Request: Subscription] = [:]
	
	private func configure(using requests: Requests) {
		for each in Set(inFlight.keys).subtracting(requests) {
			inFlight[each]!.cancel()
			inFlight.removeValue(forKey: each)
		}
		for each in requests.subtracting(inFlight.keys) {
			let command = createSubscription(each)
			inFlight[each] = command
			command.launch(dispatcher: dispatcher)
		}
	}
}
