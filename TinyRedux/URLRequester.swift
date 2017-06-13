//
//  URLRequester.swift
//  TinyRedux
//
//  Created by Daniel Tartaglia on 3/23/17.
//  Copyright © 2017 Daniel Tartaglia. All rights reserved.
//

import Foundation


/// Logic
public
enum URLRequesterEvent: Event {
	case success(request: URLRequest, data: Data, response: URLResponse)
	case failure(request: URLRequest, error: Error)
	
	public
	var request: URLRequest {
		switch self {
		case .success(let (request, _, _)):
			return request
		case .failure(let (request, _)):
			return request
		}
	}
}

public typealias URLRequesterState = Set<URLRequest>


/// Implementation
public final class URLRequester<State> {

	public init(session: URLSession = URLSession.shared, store: Store<State>, lens: @escaping (State) -> URLRequesterState) {
		self.session = session
		self.store = store
		unsubscriber = store.subscribe { [weak self] (state) in
			let requesterState = lens(state)
			self?.configure(using: requesterState)
		}
	}

	private let session: URLSession
	private let store: Store<State>
	private var unsubscriber: Unsubscriber?
	private var current: [URLRequest: URLSessionTask] = [:]

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
		let dataTask = session.dataTask(with: request) { (data, response, error) in
			DispatchQueue.main.async {
				if let data = data, let response = response {
					self.store.dispatch(event: URLRequesterEvent.success(request: request, data: data, response: response))
				}
				if let error = error {
					self.store.dispatch(event: URLRequesterEvent.failure(request: request, error: error))
				}
			}
		}
		current[request] = dataTask
		dataTask.resume()
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
