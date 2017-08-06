//
//  ViewControllerPresentationComponent.swift
//  Apex
//
//  Created by Daniel Tartaglia on 3/15/17.
//  Copyright © 2017 Daniel Tartaglia. MIT License.
//

import UIKit

public protocol ViewController: Hashable {
	associatedtype State
	func create(_ state: State) -> UIViewController
}

public final class ViewControllerPresentationComponent<P: Publisher, VC: ViewController> where VC.State == P.State {

	public init(rootViewController: UIViewController, publisher: P, lens: @escaping (P.State) -> [VC]) {
		self.lens = lens
		self.rootViewController = rootViewController
		unsubscriber = publisher.subscribe(observer: { [weak self] state in
			self?.configure(using: state)
		})
	}

	private var unsubscriber: Unsubscriber?
	private var currentStack: [VC] = []
	private var viewControllers: [VC: WeakBox<UIViewController>] = [:]
	private let queue = DispatchQueue(label: "view_controller_presenter")
	private let lens: (P.State) -> [VC]
	private let rootViewController: UIViewController

	private func configure(using state: P.State) {
		let presentationStack = lens(state)
		queue.async {
			self.cull()
			popPush(current: self.currentStack, target: presentationStack, pop: self.pop, push: self.push(state: state))
			self.currentStack = presentationStack
		}
	}

	private func pop(id: VC, isLast: Bool) -> Void {
		let semaphore = DispatchSemaphore(value: 0)
		let top = topViewController()
		guard self.viewControllers.values.contains(where: { $0.value == top }) else { return }
		assert(top != self.rootViewController, "Can't dismiss the root view controller. Did you forget fill in the alert IDs?")
		DispatchQueue.main.async {
			top.dismiss(animated: isLast, completion: {
				semaphore.signal()
			})
		}
		semaphore.wait()
	}

	private func push(state: P.State) -> (VC, Bool) -> Void {
		return { id, isLast in
			let semaphore = DispatchSemaphore(value: 0)
			DispatchQueue.main.async {
				let vc = id.create(state)
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

private struct WeakBox<T> where T: ReferenceObject {
	weak var value: T?
}

extension UIViewController: ReferenceObject { }

private func topViewController() -> UIViewController {
	guard let rootViewController = UIApplication.shared.delegate?.window??.rootViewController else { fatalError("No view controller present in app?") }
	var result = rootViewController
	while let vc = result.presentedViewController {
		result = vc
	}
	return result
}
