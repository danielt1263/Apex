//
//  PopPushAlgorithm.swift
//  TinyRedux
//
//  Created by Daniel Tartaglia on 3/18/17.
//  Copyright © 2017 Daniel Tartaglia. All rights reserved.
//

import Foundation


func popPush(current: [String], target: [String], pop: (String) -> Void, push: (String) -> Void) {
	
	var count = current.count
	if let indexOfChange = Array(zip(current, target)).index(where: { $0 != $1 }) {
		while count > indexOfChange {
			count -= 1
			pop(current[count])
		}
	}
	while count > target.count {
		count -= 1
		pop(current[count])
	}

	while count < target.count {
		push(target[count])
		count += 1
	}
}
