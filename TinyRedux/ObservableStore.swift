//
//  ObservableStore.swift
//  TinyRedux
//
//  Created by Daniel Tartaglia on 3/15/17.
//  Copyright © 2017 Daniel Tartaglia. MIT License.
//

import Foundation


public protocol ObservableStore {
	associatedtype State
	func subscribe<T>(observer: @escaping (T) -> Void, lens: @escaping (State) -> T) -> Unsubscriber
}
