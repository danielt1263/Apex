//
//  SubscriptionComponent.swift
//  Apex
//
//  Created by Daniel Tartaglia on 7/22/17.
//  Copyright © 2017 Daniel Tartaglia. MIT License.
//

import Foundation


public final
class SubscriptionComponent<Request: Hashable, A> {
	public typealias Action = A
	public typealias Requests = Set<Request>
	
	public init<State, Sub>(store: Store<State, Action>, lens: @escaping (State) -> Requests, subscriptionFactory: @escaping (Request) -> Sub) where Sub: Subscription, Sub.Action == Action {
		dispatcher = AnyDispatcher(store)
		createSubscription = { AnySubscription(subscriptionFactory($0)) }
		unsubscriber = store.subscribe(observer: { [weak self] state in
			self?.configure(using: lens(state))
		})
	}

	private let dispatcher: AnyDispatcher<Action>
	private let createSubscription: (Request) -> AnySubscription<Action>
	private var unsubscriber: Unsubscriber?
	private var inFlight: [Request: AnySubscription<Action>] = [:]
	
	private func configure(using requests: Requests) {
		for each in Set(inFlight.keys).subtracting(requests) {
			inFlight[each]!.cancel()
			inFlight.removeValue(forKey: each)
		}
		for each in requests.subtracting(inFlight.keys) {
			let subscription = createSubscription(each)
			inFlight[each] = subscription
			subscription.launch(dispatcher: dispatcher)
		}
	}
}
