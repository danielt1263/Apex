//
//  Timer.swift
//  Apex
//
//  Created by Daniel Tartaglia on 4/5/18.
//  Copyright © 2018 Daniel Tartaglia. All rights reserved.
//

import Foundation

public
class Timer: Subscription {
	public
	init(duration: TimeInterval, action: @escaping @autoclosure () -> Action) {
		self.duration = duration
		self.action = action
	}

	public
	func launch(dispatcher: Dispatcher) {
		canceled = false
		DispatchQueue.main.asyncAfter(deadline: .now() + duration) { [weak self] in
			guard let this = self else { return }
			if !this.canceled {
				dispatcher.dispatch(action: this.action())
			}
		}
	}

	public
	func cancel() {
		canceled = true
	}

	public
	var hashValue: Int {
		return duration.hashValue
	}

	public
	static func ==(lhs: Timer, rhs: Timer) -> Bool {
		return lhs.duration == rhs.duration
	}

	private let duration: TimeInterval
	private let action: () -> Action
	private var canceled: Bool = false
}
