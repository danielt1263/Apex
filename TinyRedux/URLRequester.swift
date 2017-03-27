//
//  URLRequester.swift
//  Marksman 2
//
//  Created by Daniel Tartaglia on 3/23/17.
//  Copyright © 2017 Daniel Tartaglia. All rights reserved.
//

import Foundation

// Logic
public
enum URLRequesterEvent: Event {
	case success(data: Data, response: URLResponse)
	case failure(error: Error, response: URLResponse)

	public
	var response: URLResponse {
		switch self {
		case .success(let (_, response)), .failure(let (_, response)):
			return response
		}
	}
}

public typealias URLRequesterState = Set<URLRequest>

// Implementation
public final class URLRequester<State> {

	public init(store: Store<State>, lens: @escaping (State) -> URLRequesterState) {
		self.store = store
		unsubscribe = store.subscribe { [weak self] state in
			let requests = lens(state)
			self?.configure(using: requests)
		}
	}

	private func configure(using target: URLRequesterState) {
		cancelLaunch(current: Set(current.keys), target: target, cancel: self.cancel, launch: self.launch)
	}

	private func cancel(request: URLRequest) {
		if let dataTask = current[request] {
			dataTask.cancel()
			current.removeValue(forKey: request)
		}
	}

	private func launch(request: URLRequest) {
		let dataTask = URLSession.shared.dataTask(with: request) { (data, response, error) in
			guard let response = response else { return }
			DispatchQueue.main.async {
				if let data = data {
					self.store.dispatch(event: URLRequesterEvent.success(data: data, response: response))
				}
				if let error = error {
					self.store.dispatch(event: URLRequesterEvent.failure(error: error, response: response))
				}
			}
		}
		current[request] = dataTask
		dataTask.resume()
	}

	let store: Store<State>
	var unsubscribe: Unsubscriber?
	var current: [URLRequest: URLSessionTask] = [:]
}

public func cancelLaunch<T>(current: Set<T>, target: Set<T>, cancel: (T) -> Void, launch: (T) -> Void) {
	for each in current.subtracting(target) {
		cancel(each)
	}
	for each in target.subtracting(current) {
		launch(each)
	}
}
