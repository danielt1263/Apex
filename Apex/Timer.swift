//
//  Timer.swift
//  Apex
//
//  Created by Daniel Tartaglia on 4/5/18.
//  Copyright © 2018 Daniel Tartaglia. All rights reserved.
//

import Foundation

class Timer: Subscription {
	init(duration: TimeInterval, action: @escaping @autoclosure () -> Action) {
		self.duration = duration
		self.action = action
	}

	func launch(dispatcher: Dispatcher) {
		canceled = false
		DispatchQueue.main.asyncAfter(deadline: .now() + duration) { [weak self] in
			guard let this = self else { return }
			if !this.canceled {
				dispatcher.dispatch(action: this.action())
			}
		}
	}

	func cancel() {
		canceled = true
	}

	var hashValue: Int {
		return duration.hashValue
	}

	static func ==(lhs: Timer, rhs: Timer) -> Bool {
		return lhs.duration == rhs.duration
	}

	let duration: TimeInterval
	let action: () -> Action
	var canceled: Bool = false
}
