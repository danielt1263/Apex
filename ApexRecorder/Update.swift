//
//  Update.swift
//  ApexRecorder
//
//  Created by Daniel Tartaglia on 7/23/17.
//  Copyright © 2017 Daniel Tartaglia. MIT License.
//

import Redux


public enum RecorderAction: Action {
	case undo
	case redo
}

public func recordableReducer<T>(reducer: @escaping (T, Action) -> T) -> (Recordable<T>, Action) -> Recordable<T> {
	return { state, action in
		var result = state
		switch action {
		case RecorderAction.undo:
			if !state.past.isEmpty {
				result.future.append(state.present)
				result.present = state.past.last!
				result.past.removeLast()
			}
		case RecorderAction.redo:
			if !state.future.isEmpty {
				result.past.append(state.present)
				result.present = state.future.last!
				result.future.removeLast()
			}
		default:
			result.past.append(state.present)
			result.present = reducer(state.present, action)
			result.future = []
		}
		return result
	}
}
