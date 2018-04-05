//
//  URLCommand.swift
//  Apex
//
//  Created by Daniel Tartaglia on 12/17/17.
//  Copyright © 2017 Daniel Tartaglia. MIT License
//

public
struct URLCommand: Command, Equatable {

	public
	init(session: URLSession, request: URLRequest, action: URLCommandActionCreator?) {
		self.session = session
		self.request = request
		self.action = action
	}

	public
	func execute(dispatcher: Dispatcher) {
		session.dataTask(with: request) { (data, response, error) in
			if let action = self.action {
				if let data = data, let response = response {
					dispatcher.dispatch(action: action(.success((data, response))))
				}
				else {
					dispatcher.dispatch(action: action(.failure(error ?? UnknownError())))
				}
			}
		}.resume()
	}

	public
	static func ==(lhs: URLCommand, rhs: URLCommand) -> Bool {
		return lhs.request == rhs.request
	}

	private let session: URLSession
	private let request: URLRequest
	private let action: URLCommandActionCreator?
}

public
typealias URLCommandActionCreator = (URLCommandUpdate) -> Action

public
enum URLCommandUpdate {
	case success(Data, URLResponse)
	case failure(Error)
}
