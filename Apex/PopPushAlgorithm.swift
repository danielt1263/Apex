//
//  PopPushAlgorithm.swift
//  Apex
//
//  Created by Daniel Tartaglia on 3/18/17.
//  Copyright © 2017 Daniel Tartaglia. MIT License.
//


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

public
func popPushExpress<T>(current: [T], target: [T], popTo: (Int, _ isLast: Bool) -> Void, push: (T, _ isLast: Bool) -> Void) where T: Equatable {
	guard current != target else { return }
	if let indexOfChange = Array(zip(current, target)).index(where: { $0 != $1 }) {
		popTo(indexOfChange - 1, false)
		handlePushes(currentIndex: indexOfChange, target: target, push: push)
	}
	else if current.count > target.count {
		if !target.isEmpty {
			popTo(target.count - 1, true)
		}
	}
		
	handlePushes(currentIndex: current.count, target: target, push: push)
}

private
func handlePushes<T>(currentIndex: Int, target: [T], push: (T, _ isLast: Bool) -> Void) where T: Equatable {
	if currentIndex < target.count {
		for item in target[currentIndex ..< target.count] {
			push(item, item == target.last)
		}
	}
}

