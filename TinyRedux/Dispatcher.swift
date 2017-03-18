//
//  Dispatcher.swift
//  Async
//
//  Created by Daniel Tartaglia on 3/15/17.
//  Copyright © 2017 Daniel Tartaglia. All rights reserved.
//

import Foundation


public protocol Dispatcher {
	associatedtype Action
	func dispatch(action: Action)
}
