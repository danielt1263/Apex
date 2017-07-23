//
//  State.swift
//  ApexRecorder
//
//  Created by Daniel Tartaglia on 7/23/17.
//  Copyright © 2017 Daniel Tartaglia. MIT License.
//

import Redux


public protocol RecorderState {
	associatedtype Wrapped
	var present: Wrapped { get }
}

public struct Recordable<T>: RecorderState {
	public typealias Wrapped = T
	public var past: [T] = []
	public var present: T
	public var future: [T] = []
	
	public init(state: T) {
		present = state
	}
}

public extension Redux.Store where State: RecorderState {
	
	func subscribe(observer: @escaping (State.Wrapped) -> Void) -> Unsubscriber {
		return subscribe(observer: { observer($0.present) })
	}
}
