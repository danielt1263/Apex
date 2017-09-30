//
//  NavigationComponent.swift
//  Apex
//
//  Created by Daniel Tartaglia on 9/30/17.
//  Copyright © 2017 Daniel Tartaglia. All rights reserved.
//

import UIKit


public final
class NavigationComponent<P: Publisher, VC: ViewControllerFactory>
	where VC.State == P.State {

	init(navController: UINavigationController, publisher: P, lens: @escaping (P.State) -> [VC]) {
		self.navController = navController
		self.publisher = publisher
		self.lens = lens
		unsubscriber = publisher.subscribe(observer: { [weak self] state in
			self?.configure(with: state)
		})
	}
	
	private let navController: UINavigationController
	private let publisher: P
	private let lens: (P.State) -> [VC]
	private var unsubscriber: Unsubscriber?
	private var currentStack: [VC] = []

	private func configure(with state: VC.State) {
		let newStack = lens(state)
		popPushExpress(current: self.currentStack, target: newStack, popTo: self.pop, push: self.push(state: state))
		self.currentStack = newStack
	}

	private func pop(index: Int, animated: Bool) {
		navController.popToViewController(navController.viewControllers[index], animated: animated)
	}
	
	private func push(state: P.State) -> (VC, Bool) -> Void {
		return { vc, isLast in
			let controller = vc.create(state)
			if self.navController.viewControllers.isEmpty {
				self.navController.viewControllers = [controller]
			}
			else {
				self.navController.pushViewController(controller, animated: isLast)
			}
		}
	}
}
