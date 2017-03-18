//
//  ThunkMiddleware.swift
//  Marksman 2
//
//  Created by Daniel Tartaglia on 3/18/17.
//  Copyright © 2017 Daniel Tartaglia. All rights reserved.
//

import Foundation


public
protocol Thunkable {
	associatedtype Store
	var asThunk: ((Store) -> Void)? { get }
}

public
func thunk<S, A>(store: Store<S, A>, next: @escaping Store<S, A>.Dispatcher) -> Store<S, A>.Dispatcher where A: Thunkable, A.Store == Store<S, A> {
	return { action in
		if let thunk = action.asThunk {
			thunk(store)
		}
		else {
			next(action)
		}
	}
}
