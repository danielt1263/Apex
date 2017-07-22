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
enum URLRequesterEvent: Action {
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

class URLRequestCommand: Command {
	
	init(request: URLRequest, session: URLSession = URLSession.shared) {
		self.request = request
		self.session = session
	}

	func cancel() {
		dataTask?.cancel()
		dataTask = nil
	}
	
	func launch(dispatcher: @escaping Dispatcher) {
		dataTask = session.dataTask(with: request) { (data, response, error) in
			DispatchQueue.main.async {
				if let data = data, let response = response {
					dispatcher(URLRequesterEvent.success(request: self.request, data: data, response: response))
				}
				if let error = error {
					dispatcher(URLRequesterEvent.failure(request: self.request, error: error))
				}
			}
		}
		dataTask?.resume()
	}
	
	var hashValue: Int { return request.hashValue }
	
	static func ==(lhs: URLRequestCommand, rhs: URLRequestCommand) -> Bool {
		return lhs.session == rhs.session
	}
	
	private let session: URLSession
	private let request: URLRequest
	private var dataTask: URLSessionDataTask?
}

/// Implementation
public final class URLRequester<State> {

	public init(session: URLSession = URLSession.shared, store: Store<State>, lens: @escaping (State) -> URLRequesterState) {
		let commandLens = { Set(lens($0).map({ AnyCommand(URLRequestCommand(request: $0, session: session)) })) }
		
		self.commandManager = CommandManager(store: store, lens: commandLens)
	}

	private let commandManager: CommandManager<State>
}
