//
//  Command.swift
//  Apex
//
//  Created by Daniel Tartaglia on 11/27/17.
//  Copyright © 2017 Daniel Tartaglia. All rights reserved.
//

import Foundation


public final class Command {
	public init(work: @escaping (Dispatcher) -> Void) {
		self.work = work
	}

	func execute(_ dispatcher: Dispatcher) {
		work(dispatcher)
	}

	private let work: (Dispatcher) -> Void
}
