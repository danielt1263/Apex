//
//  State.swift
//  ApexRecorder
//
//  Created by Daniel Tartaglia on 7/23/17.
//  Copyright © 2017 Daniel Tartaglia. MIT License.
//

import Apex


public protocol RecorderState: State {
	associatedtype Wrapped
	var present: Wrapped { get }
}

public enum RecorderAction: Action {
	case undo
	case redo
}

public struct Recordable<T: State>: RecorderState {
	public typealias Wrapped = T
	public var past: [T] = []
	public var present: T
	public var future: [T] = []
	
	public init(state: T) {
		present = state
	}
	
	public mutating func transition(_ action: Action) {
		switch action {
		case RecorderAction.undo:
			if !past.isEmpty {
				future.append(present)
				present = past.last!
				past.removeLast()
			}
		case RecorderAction.redo:
			if !future.isEmpty {
				past.append(present)
				present = future.last!
				future.removeLast()
			}
		default:
			past.append(present)
			present.transition(action)
			future = []
		}
	}
}

public extension Store where State: RecorderState {
	
	func subscribe(observer: @escaping (State.Wrapped) -> Void) -> Unsubscriber {
		return subscribe(observer: { observer($0.present) })
	}
}
