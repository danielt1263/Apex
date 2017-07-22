//
//  PopPushAlgorithm.swift
//  Apex
//
//  Created by Daniel Tartaglia on 3/18/17.
//  Copyright © 2017 Daniel Tartaglia. MIT License.
//

import Foundation


public
func popPush<T>(current: [T], target: [T], pop: (T, _ isLast: Bool) -> Void, push: (T, _ isLast: Bool) -> Void) where T: Equatable {

	var count = current.count
	if let indexOfChange = Array(zip(current, target)).index(where: { $0 != $1 }) {
		while count > indexOfChange {
			count -= 1
			pop(current[count], false)
		}
	}
	while count > target.count {
		count -= 1
		pop(current[count], count == target.count)
	}

	while count < target.count {
		push(target[count], count == target.count - 1)
		count += 1
	}
}
