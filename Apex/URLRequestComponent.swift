//
//  URLRequestComponent.swift
//  Apex
//
//  Created by Daniel Tartaglia on 3/23/17.
//  Copyright © 2017 Daniel Tartaglia. MIT License.
//

public typealias URLRequesterState = Set<URLRequest>

public final class URLRequestComponent {
	
	public init<S: State>(store: Store<S>, lens: @escaping (S) -> URLRequesterState, session: URLSession = URLSession.shared) {
		let commandLens = { state in
			Set(lens(state).map { URLRequestCommand(request: $0, session: session) })
		}
		self.commandManager = CommandComponent(store: store, lens: commandLens)
	}
	
	private let commandManager: CommandComponent<URLRequestCommand>
}

public final class URLRequestCommand: Command {
	
	public init(request: URLRequest, session: URLSession = URLSession.shared) {
		self.request = request
		self.session = session
	}
	
	public func cancel() {
		dataTask?.cancel()
		dataTask = nil
	}
	
	public func launch(dispatcher: Dispatcher) {
		dataTask = session.dataTask(with: request) { (data, response, error) in
			DispatchQueue.main.async {
				if let data = data, let response = response {
					dispatcher.dispatch(action: URLRequesterAction.success(request: self.request, data: data, response: response))
				}
				if let error = error {
					dispatcher.dispatch(action: URLRequesterAction.failure(request: self.request, error: error))
				}
			}
		}
		dataTask?.resume()
	}
	
	public var hashValue: Int { return request.hashValue }
	
	public static func ==(lhs: URLRequestCommand, rhs: URLRequestCommand) -> Bool {
		return lhs.session == rhs.session
	}
	
	private let session: URLSession
	private let request: URLRequest
	private var dataTask: URLSessionDataTask?
}

public enum URLRequesterAction: Action {
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
