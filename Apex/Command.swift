//
//  Command.swift
//  Apex
//
//  Created by Daniel Tartaglia on 11/27/17.
//  Copyright © 2017 Daniel Tartaglia. All rights reserved.
//

import Foundation


public final class Command {
	init(work: @escaping (@escaping (Action) -> Void) -> Void) {
		self.work = work
	}

	func execute(_ f: @escaping (Action) -> Void) {
		retain = self
		listener = f
		work(self.fulfill)
	}

	private func fulfill(msg: Action) {
		if let listener = listener {
			listener(msg)
			self.listener = nil
			self.retain = nil
		}
	}

	private let work: (@escaping (Action) -> Void) -> Void
	private var listener: ((Action) -> Void)?
	private var retain: Command?
}
