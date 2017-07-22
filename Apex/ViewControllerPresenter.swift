//
//  ViewControllerPresenter.swift
//  Apex
//
//  Created by Daniel Tartaglia on 3/15/17.
//  Copyright © 2017 Daniel Tartaglia. MIT License.
//

import UIKit


public final class ViewControllerPresenter<State, ViewControllerID: Hashable> {

	public typealias ViewControllerPresenterState = [ViewControllerID]

	public init(rootViewController: UIViewController, factory: [ViewControllerID: (State) -> UIViewController], store: Store<State>, lens: @escaping (State) -> ViewControllerPresenterState) {
		self.factory = factory
		self.lens = lens
		self.rootViewController = rootViewController
		unsubscriber = store.subscribe(observer: { [weak self] state in
			self?.configure(using: state)
		})
	}

	private var unsubscriber: Unsubscriber?
	private var currentStack: [ViewControllerID] = []
	private var viewControllers: [ViewControllerID: WeakBox<UIViewController>] = [:]
	private let queue = DispatchQueue(label: "view_controller_presenter")
	private let factory: [ViewControllerID: (State) -> UIViewController]
	private let lens: (State) -> ViewControllerPresenterState
	private let rootViewController: UIViewController

	private func configure(using state: State) {
		let presentationStack = lens(state)
		queue.async {
			self.cull()
			popPush(current: self.currentStack, target: presentationStack, pop: self.pop, push: self.push(state: state))
			self.currentStack = presentationStack
		}
	}

	private func pop(id: ViewControllerID, isLast: Bool) -> Void {
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

	private func push(state: State) -> (ViewControllerID, Bool) -> Void {
		return { id, isLast in
			let semaphore = DispatchSemaphore(value: 0)
			guard let vc = self.factory[id]?(state) else { fatalError("can't construct view controller \(id)") }
			self.viewControllers[id] = WeakBox(value: vc)
			let top = topViewController()
			DispatchQueue.main.async {
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
