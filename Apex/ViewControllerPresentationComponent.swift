//
//  ViewControllerPresentationComponent.swift
//  Apex
//
//  Created by Daniel Tartaglia on 3/15/17.
//  Copyright © 2017 Daniel Tartaglia. MIT License.
//

import UIKit


public final
class ViewControllerPresentationComponent<P: Publisher, ViewControllerID: Hashable> {

	public init(root: UIViewController, publisher: P, lens: @escaping (P.State) -> [ViewControllerID], factory: @escaping (ViewControllerID, P.State) -> UIViewController) {
		rootViewController = root
		self.lens = lens
		createViewController = factory
		unobserver = publisher.observe(observer: { [weak self] state in
			self?.configure(using: state)
		})
	}

	private var unobserver: Unobserver?
	private var currentStack: [ViewControllerID] = []
	private var viewControllers: [ViewControllerID: WeakBox<UIViewController>] = [:]
	private let queue = DispatchQueue(label: "view_controller_presenter")
	private let rootViewController: UIViewController
	private let lens: (P.State) -> [ViewControllerID]
	private let createViewController: (ViewControllerID, P.State) -> UIViewController

	private func configure(using state: P.State) {
		let presentationStack = lens(state)
		// the delay is needed to ensure that UIAlertControllers are fully deleted before culling happens.
		queue.asyncAfter(deadline: .now() + 0.2) {
			self.cull()
			popPushExpress(current: self.currentStack, target: presentationStack, popTo: self.popTo, push: self.push(state: state))
			self.currentStack = presentationStack
		}
	}

	private func popTo(index: Int, isLast: Bool) {
		let semaphore = DispatchSemaphore(value: 0)
		DispatchQueue.main.async {
			if index == -1 {
				self.rootViewController.dismiss(animated: isLast || self.currentStack.count < index + 2, completion: {
					semaphore.signal()
				})
			}
			else {
				let id = self.currentStack[index]
				if let vc = self.viewControllers[id]?.value {
					vc.dismiss(animated: isLast || self.currentStack.count < index + 2, completion: {
						semaphore.signal()
					})
				}
			}
		}
		semaphore.wait()
	}

	private func push(state: P.State) -> (ViewControllerID, Bool) -> Void {
		return { id, isLast in
			let semaphore = DispatchSemaphore(value: 0)
			DispatchQueue.main.async {
				let vc = self.createViewController(id, state)
				self.viewControllers[id] = WeakBox(value: vc)
				let top = topViewController()
				top.present(vc, animated: isLast, completion: {
					semaphore.signal()
				})
			}
			semaphore.wait()
		}
	}

	private func cull() {
		for (key, box) in viewControllers {
			if box.value == nil {
				viewControllers.removeValue(forKey: key)
			}
		}
		while let i = currentStack.index(where: { !viewControllers.keys.contains($0) }) {
			currentStack.remove(at: i)
		}
	}

}

protocol ReferenceObject: class { }

private
struct WeakBox<T> where T: ReferenceObject {
	weak var value: T?
}

extension UIViewController: ReferenceObject { }

private
func topViewController() -> UIViewController {
	guard let rootViewController = UIApplication.shared.delegate?.window??.rootViewController else { fatalError("No view controller present in app?") }
	var result = rootViewController
	while let vc = result.presentedViewController {
		result = vc
	}
	return result
}
