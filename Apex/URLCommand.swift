//
//  URLCommand.swift
//  Apex
//
//  Created by Daniel Tartaglia on 12/17/17.
//  Copyright © 2017 Daniel Tartaglia. MIT License
//

struct URLCommand: Command, Equatable {

	init(session: URLSession, request: URLRequest, action: @escaping (Result<(Data, URLResponse)>) -> Action) {
		self.session = session
		self.request = request
		self.action = action
	}

	func execute(dispatcher: Dispatcher) {
		session.dataTask(with: request) { (data, response, error) in
			let action: Action
			if let data = data, let response = response {
				action = self.action(.success((data, response)))
			}
			else {
				action = self.action(.failure(error ?? UnknownError()))
			}
			dispatcher.dispatch(action: action)
		}
	}

	static func ==(lhs: URLCommand, rhs: URLCommand) -> Bool {
		return lhs.request == rhs.request
	}

	private let session: URLSession
	private let request: URLRequest
	private let action: (Result<(Data, URLResponse)>) -> Action
}
