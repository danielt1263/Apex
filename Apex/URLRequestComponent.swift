//
//  URLRequestComponent.swift
//  Apex
//
//  Created by Daniel Tartaglia on 3/23/17.
//  Copyright © 2017 Daniel Tartaglia. MIT License.
//

public final class URLRequestComponent {
	
	public init<S>(store: Store<S>, lens: @escaping (S) -> Set<URLRequest>, session: URLSession = URLSession.shared) {
		component = CommandComponent(store: store, lens: lens, commandFactory: {
			return URLRequestCommand(request: $0, session: session)
		})
	}
	
	let component: CommandComponent<URLRequest>
}

public final class URLRequestCommand: Command {
	
	public init(request: URLRequest, session: URLSession = URLSession.shared) {
		self.request = request
		self.session = session
	}
	
	public func launch(dispatcher: Dispatcher) {
		dataTask = session.dataTask(with: request) { (data, response, error) in
			self.dataTask = nil
			DispatchQueue.main.async {
				if let data = data, let response = response {
					dispatcher.dispatch(action: URLRequestAction.success(request: self.request, data: data, response: response))
				}
				if let error = error {
					dispatcher.dispatch(action: URLRequestAction.failure(request: self.request, error: error))
				}
			}
		}
		dataTask?.resume()
	}
	
	public func cancel() {
		dataTask?.cancel()
		dataTask = nil
	}
	
	private let session: URLSession
	private let request: URLRequest
	private var dataTask: URLSessionDataTask?
}

public enum URLRequestAction: Action {
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

